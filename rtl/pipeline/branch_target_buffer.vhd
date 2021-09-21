----------------------------------------------------------------------------------------------------
-- Copyright (c) 2018 Marcus Geelnard
--
-- This software is provided 'as-is', without any express or implied warranty. In no event will the
-- authors be held liable for any damages arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose, including commercial
-- applications, and to alter it and redistribute it freely, subject to the following restrictions:
--
--  1. The origin of this software must not be misrepresented; you must not claim that you wrote
--     the original software. If you use this software in a product, an acknowledgment in the
--     product documentation would be appreciated but is not required.
--
--  2. Altered source versions must be plainly marked as such, and must not be misrepresented as
--     being the original software.
--
--  3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Branch Target Buffer
--
-- This is a simple bi-modal branch predictor with a branch target buffer. The PC provided by
-- i_read_pc represents the PC that will be used during the next cycle in the IF stage, and the
-- predicted target (and whether it should be taken) is provided during the next cycle.
--
-- The branch predictor is guaranteed to never signal o_predict_taken if a branch instruction has
-- not previously been seen at the given PC (if the program memory has modified, i_invalidate must
-- be signalled to clear the predictor buffers).
--
-- Note: The two least significant bits of the PC are ignored (treated as zero).
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config.all;

entity branch_target_buffer is
  port(
      -- Control signals.
      i_clk : in std_logic;
      i_rst : in std_logic;
      i_invalidate : in std_logic;

      -- Buffer lookup (sync).
      i_read_pc : in std_logic_vector(C_WORD_SIZE-1 downto 0);
      i_read_en : in std_logic;
      o_predict_taken : out std_logic;
      o_predict_target : out std_logic_vector(C_WORD_SIZE-1 downto 0);

      -- Buffer update (sync).
      i_write_pc : in std_logic_vector(C_WORD_SIZE-1 downto 0);
      i_write_is_branch : in std_logic;
      i_write_is_taken : in std_logic;
      i_write_target : in std_logic_vector(C_WORD_SIZE-1 downto 0)
    );
end branch_target_buffer;

architecture rtl of branch_target_buffer is
  -- Number of entries in the global history buffer (0 to disable).
  constant C_GHR_BITS : integer := 0;

  -- Total number of entries in the branch target buffer.
  constant C_LOG2_ENTRIES : integer := 9;  -- 512 entries.
  constant C_NUM_ENTRIES : integer := 2**C_LOG2_ENTRIES;

  -- Size of the tag.
  constant C_TAG_SIZE : integer := C_WORD_SIZE-2 - (C_LOG2_ENTRIES - C_GHR_BITS);

  -- Size of a branch target entry.
  constant C_ENTRY_SIZE : integer := 1 + C_WORD_SIZE-2;  -- is_taken & target_address

  -- Number of bits per counter.
  constant C_COUNTER_SIZE : integer := 2;
  constant C_MAX_COUNT : integer := (2**C_COUNTER_SIZE) - 1;

  signal s_invalidating : std_logic;
  signal s_invalidate_adr : unsigned(C_LOG2_ENTRIES-1 downto 0);

  signal s_global_history : std_logic_vector(C_GHR_BITS-1 downto 0);

  signal s_prev_read_en : std_logic;
  signal s_prev_read_pc : std_logic_vector(C_WORD_SIZE-1 downto 0);
  signal s_got_match : std_logic;
  signal s_got_valid : std_logic;
  signal s_got_taken : std_logic;

  signal s_prev_write_is_branch : std_logic;
  signal s_prev_write_is_taken : std_logic;
  signal s_prev_write_addr : std_logic_vector(C_LOG2_ENTRIES-1 downto 0);
  signal s_prev_write_tag : std_logic_vector(C_TAG_SIZE-1 downto 0);
  signal s_prev_write_target : std_logic_vector(C_WORD_SIZE-3 downto 0);

  signal s_read_addr : std_logic_vector(C_LOG2_ENTRIES-1 downto 0);
  signal s_tag_read_data : std_logic_vector(C_TAG_SIZE-1 downto 0);
  signal s_target_read_data : std_logic_vector(C_ENTRY_SIZE-1 downto 0);

  signal s_counter_read_addr : std_logic_vector(C_LOG2_ENTRIES-1 downto 0);
  signal s_counter_read_data : std_logic_vector(C_COUNTER_SIZE-1 downto 0);

  signal s_write_addr : std_logic_vector(C_LOG2_ENTRIES-1 downto 0);
  signal s_we : std_logic;
  signal s_tag_write_data : std_logic_vector(C_TAG_SIZE-1 downto 0);
  signal s_target_write_data : std_logic_vector(C_ENTRY_SIZE-1 downto 0);
  signal s_updated_counter : std_logic_vector(C_COUNTER_SIZE-1 downto 0);
  signal s_counter_predicts_taken : std_logic;
  signal s_counter_write_data : std_logic_vector(C_COUNTER_SIZE-1 downto 0);

  function table_address(pc : std_logic_vector; gh : std_logic_vector) return std_logic_vector is
  begin
    return pc(C_LOG2_ENTRIES-C_GHR_BITS+2-1 downto 2) & gh;
  end function;

  function make_tag(pc : std_logic_vector) return std_logic_vector is
  begin
    return pc(C_WORD_SIZE-1 downto C_WORD_SIZE-C_TAG_SIZE);
  end function;

  function update_counter(count : std_logic_vector; is_taken : std_logic) return std_logic_vector is
    variable v_count : unsigned(C_COUNTER_SIZE-1 downto 0);
  begin
    v_count := unsigned(count);
    if is_taken = '0' and v_count > 0 then
      v_count := v_count - 1;
    elsif is_taken = '1' and v_count < C_MAX_COUNT then
      v_count := v_count + 1;
    end if;
    return std_logic_vector(v_count);
  end function;

begin
  -- Instantiate the tag RAM.
  tag_ram_0: entity work.ram_dual_port
    generic map (
      WIDTH => C_TAG_SIZE,
      ADDR_BITS => C_LOG2_ENTRIES
    )
    port map (
      i_clk => i_clk,
      i_write_addr => s_write_addr,
      i_write_data => s_tag_write_data,
      i_we => s_we,
      i_read_addr => s_read_addr,
      o_read_data => s_tag_read_data
    );

  -- Instantiate the branch target RAM.
  target_ram_0: entity work.ram_dual_port
    generic map (
      WIDTH => C_ENTRY_SIZE,
      ADDR_BITS => C_LOG2_ENTRIES
    )
    port map (
      i_clk => i_clk,
      i_write_addr => s_write_addr,
      i_write_data => s_target_write_data,
      i_we => s_we,
      i_read_addr => s_read_addr,
      o_read_data => s_target_read_data
    );

  -- Instantiate the branch counter RAM.
  counter_ram_0: entity work.ram_dual_port
    generic map (
      WIDTH => C_COUNTER_SIZE,
      ADDR_BITS => C_LOG2_ENTRIES
    )
    port map (
      i_clk => i_clk,
      i_write_addr => s_write_addr,
      i_write_data => s_counter_write_data,
      i_we => s_we,
      i_read_addr => s_counter_read_addr,
      o_read_data => s_counter_read_data
    );

  -- Internal state.
  process(i_clk, i_rst)
  begin
    if i_rst = '1' then
      s_prev_read_en <= '0';
      s_prev_read_pc <= (others => '0');
    elsif rising_edge(i_clk) then
      s_prev_read_en <= i_read_en and not s_invalidating;
      s_prev_read_pc <= i_read_pc;
    end if;
  end process;


  --------------------------------------------------------------------------------------------------
  -- Global history.
  --------------------------------------------------------------------------------------------------

  GH_GEN: if C_GHR_BITS > 0 generate
    process(i_clk, i_rst)
    begin
      if i_rst = '1' then
        s_global_history <= (others => '0');
      elsif rising_edge(i_clk) then
        if i_invalidate = '1' then
          s_global_history <= (others => '0');
        elsif i_write_is_branch = '1' then
          s_global_history <= i_write_is_taken & s_global_history(C_GHR_BITS-1 downto 1);
        end if;
      end if;
    end process;
  end generate;


  --------------------------------------------------------------------------------------------------
  -- Invalidation state machine.
  --------------------------------------------------------------------------------------------------

  process(i_clk, i_rst)
  begin
    if i_rst = '1' then
      s_invalidating <= '1';
      s_invalidate_adr <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_invalidate = '1' then
        s_invalidating <= '1';
        s_invalidate_adr <= (others => '0');
      elsif s_invalidating = '1' then
        if s_invalidate_adr = C_NUM_ENTRIES-1 then
          s_invalidating <= '0';
        end if;
        s_invalidate_adr <= s_invalidate_adr + 1;
      end if;
    end if;
  end process;


  --------------------------------------------------------------------------------------------------
  -- Buffer lookup.
  --------------------------------------------------------------------------------------------------

  s_read_addr <= table_address(i_read_pc, s_global_history);

  -- Decode the target and tag information.
  o_predict_target <= s_target_read_data(C_ENTRY_SIZE-2 downto 0) & "00";
  s_got_taken <= s_target_read_data(C_ENTRY_SIZE-1);
  s_got_match <= '1' when make_tag(s_prev_read_pc) = s_tag_read_data else '0';

  -- Determine if we should take the branch.
  o_predict_taken <= s_prev_read_en and s_got_match and s_got_taken;


  --------------------------------------------------------------------------------------------------
  -- Buffer update is done during two cycles (pipelined):
  --  1) Read the counter from the counter RAM.
  --  2)
  --     a) Update the counter (+ or - depending on is_taken).
  --     b) Write the new counter to the counter RAM, and update the tag & target RAM:s.
  --------------------------------------------------------------------------------------------------

  process(i_clk, i_rst)
  begin
    if i_rst = '1' then
      s_prev_write_is_branch <= '0';
      s_prev_write_is_taken <= '0';
      s_prev_write_addr <= (others => '0');
      s_prev_write_tag <= (others => '0');
      s_prev_write_target <= (others => '0');
    elsif rising_edge(i_clk) then
      s_prev_write_is_branch <= i_write_is_branch;
      s_prev_write_is_taken <= i_write_is_taken;
      s_prev_write_addr <= s_counter_read_addr;
      s_prev_write_tag <= make_tag(i_write_pc);
      s_prev_write_target <= i_write_target(C_WORD_SIZE-1 downto 2);
    end if;
  end process;

  -- In the first cycle, read from the counter RAM.
  s_counter_read_addr <= table_address(i_write_pc, s_global_history);

  -- Update the counter, and determine if the next prediction should be taken or not.
  s_updated_counter <= update_counter(s_counter_read_data, s_prev_write_is_taken);
  s_counter_predicts_taken <= s_updated_counter(C_COUNTER_SIZE-1);  -- MSB of counter = predict taken

  -- Prepare write operations to the different RAM:s.
  s_we <= s_invalidating or s_prev_write_is_branch;
  s_write_addr <= std_logic_vector(s_invalidate_adr) when s_invalidating = '1' else
                  s_prev_write_addr;
  s_tag_write_data <= (others => '0') when s_invalidating = '1' else
                      s_prev_write_tag;
  s_target_write_data <= (others => '0') when s_invalidating = '1' else
                         s_counter_predicts_taken & s_prev_write_target;
  s_counter_write_data <= (C_COUNTER_SIZE-1 => '0', others => '1') when s_invalidating = '1' else
                          s_updated_counter;
end rtl;
