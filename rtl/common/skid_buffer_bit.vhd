----------------------------------------------------------------------------------------------------
-- Copyright (c) 2021 Marcus Geelnard
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
-- This is a single-bit signal implementation of the skid_buffer.
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity skid_buffer_bit is
  port(
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_stall : in std_logic;

    i_d : in std_logic;
    o_q : out std_logic
  );
end skid_buffer_bit;

architecture rtl of skid_buffer_bit is
  signal s_d_latched : std_logic;
begin
  -- Latch D during stall.
  process(i_clk, i_rst)
  begin
    if i_rst = '1' then
      s_d_latched <= '0';
    elsif rising_edge(i_clk) then
      if i_stall = '1' then
        if i_d = '1' then
          s_d_latched <= '1';
        end if;
      else
        s_d_latched <= '0';
      end if;
    end if;
  end process;

  -- Select output signal.
  o_q <= i_d or s_d_latched;
end rtl;
