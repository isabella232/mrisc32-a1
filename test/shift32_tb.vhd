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

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.types.all;

entity shift32_tb is
end shift32_tb;

architecture behavioral of shift32_tb is
  signal s_op          : T_ALU_OP;
  signal s_src         : std_logic_vector(31 downto 0);
  signal s_dst         : std_logic_vector(31 downto 0);
  signal s_ctrl        : std_logic_vector(31 downto 0);
  signal s_packed_mode : T_PACKED_MODE;
  signal s_result      : std_logic_vector(31 downto 0);

  function ctrl32(w: integer; o: integer) return std_logic_vector is
  begin
    return 19x"0" & to_vector(w, 5) & "000" & to_vector(o, 5);
  end function;

  function ctrl16(w1: integer; o1: integer;
                  w2: integer; o2: integer) return std_logic_vector is
  begin
    return "0000" & to_vector(w1, 4) & "0000" & to_vector(o1, 4) &
           "0000" & to_vector(w2, 4) & "0000" & to_vector(o2, 4);
  end function;

  function ctrl8(w1: integer; o1: integer;
                 w2: integer; o2: integer;
                 w3: integer; o3: integer;
                 w4: integer; o4: integer) return std_logic_vector is
  begin
    return "0" & to_vector(w1, 3) & "0" & to_vector(o1, 3) &
           "0" & to_vector(w2, 3) & "0" & to_vector(o2, 3) &
           "0" & to_vector(w3, 3) & "0" & to_vector(o3, 3) &
           "0" & to_vector(w4, 3) & "0" & to_vector(o4, 3);
  end function;

begin
  shift32_0: entity work.shift32
    generic map (
      CONFIG => C_CORE_CONFIG_FULL
    )
    port map (
      i_op => s_op,
      i_src => s_src,
      i_dst => s_dst,
      i_ctrl => s_ctrl,
      i_packed_mode => s_packed_mode,
      o_result => s_result
    );

  process
    --  The patterns to apply.
    type pattern_type is record
      -- Inputs
      op          : T_ALU_OP;
      src         : std_logic_vector(31 downto 0);
      ctrl        : std_logic_vector(31 downto 0);
      packed_mode : T_PACKED_MODE;

      -- Expected outputs
      result     : std_logic_vector(31 downto 0);
    end record;
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array := (
        -- EBF
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,0), C_PACKED_NONE, "10001111000001110000001100000001"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,1), C_PACKED_NONE, "11000111100000111000000110000000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,2), C_PACKED_NONE, "11100011110000011100000011000000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,3), C_PACKED_NONE, "11110001111000001110000001100000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,4), C_PACKED_NONE, "11111000111100000111000000110000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,5), C_PACKED_NONE, "11111100011110000011100000011000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,6), C_PACKED_NONE, "11111110001111000001110000001100"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,7), C_PACKED_NONE, "11111111000111100000111000000110"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,8), C_PACKED_NONE, "11111111100011110000011100000011"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,9), C_PACKED_NONE, "11111111110001111000001110000001"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,10), C_PACKED_NONE, "11111111111000111100000111000000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,11), C_PACKED_NONE, "11111111111100011110000011100000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,12), C_PACKED_NONE, "11111111111110001111000001110000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,13), C_PACKED_NONE, "11111111111111000111100000111000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,14), C_PACKED_NONE, "11111111111111100011110000011100"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,15), C_PACKED_NONE, "11111111111111110001111000001110"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,16), C_PACKED_NONE, "11111111111111111000111100000111"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,17), C_PACKED_NONE, "11111111111111111100011110000011"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,18), C_PACKED_NONE, "11111111111111111110001111000001"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,19), C_PACKED_NONE, "11111111111111111111000111100000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,20), C_PACKED_NONE, "11111111111111111111100011110000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,21), C_PACKED_NONE, "11111111111111111111110001111000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,22), C_PACKED_NONE, "11111111111111111111111000111100"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,23), C_PACKED_NONE, "11111111111111111111111100011110"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,24), C_PACKED_NONE, "11111111111111111111111110001111"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,25), C_PACKED_NONE, "11111111111111111111111111000111"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,26), C_PACKED_NONE, "11111111111111111111111111100011"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,27), C_PACKED_NONE, "11111111111111111111111111110001"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,28), C_PACKED_NONE, "11111111111111111111111111111000"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,29), C_PACKED_NONE, "11111111111111111111111111111100"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,30), C_PACKED_NONE, "11111111111111111111111111111110"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(0,31), C_PACKED_NONE, "11111111111111111111111111111111"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(16,7), C_PACKED_NONE, "00000000000000000000111000000110"),
        (C_ALU_EBF,  "10001111000001110000001100000001", ctrl32(16,9), C_PACKED_NONE, "11111111111111111000001110000001"),

        (C_ALU_EBF,  "10001111000001111000001100000001", ctrl16(0,0, 0,1), C_PACKED_HALF_WORD, "10001111000001111100000110000000"),
        (C_ALU_EBF,  "10001111000001111000001100000001", ctrl16(0,2, 0,3), C_PACKED_HALF_WORD, "11100011110000011111000001100000"),
        (C_ALU_EBF,  "10001111000001111000001100000001", ctrl16(0,4, 0,5), C_PACKED_HALF_WORD, "11111000111100001111110000011000"),
        (C_ALU_EBF,  "10001111000001111000001100000001", ctrl16(0,6, 0,7), C_PACKED_HALF_WORD, "11111110001111001111111100000110"),
        (C_ALU_EBF,  "10001111000001111000001100000001", ctrl16(0,8, 0,9), C_PACKED_HALF_WORD, "11111111100011111111111111000001"),
        (C_ALU_EBF,  "10001111000001111000001100000001", ctrl16(0,10, 0,11), C_PACKED_HALF_WORD, "11111111111000111111111111110000"),
        (C_ALU_EBF,  "10001111000001111000001100000001", ctrl16(0,12, 0,13), C_PACKED_HALF_WORD, "11111111111110001111111111111100"),
        (C_ALU_EBF,  "10001111000001111000001100000001", ctrl16(0,14, 0,15), C_PACKED_HALF_WORD, "11111111111111101111111111111111"),

        (C_ALU_EBF,  "10001111100001111000001110000001", ctrl8(0,0, 0,1, 0,2, 0,3), C_PACKED_BYTE, "10001111110000111110000011110000"),
        (C_ALU_EBF,  "10001111100001111000001110000001", ctrl8(0,4, 0,5, 0,6, 0,7), C_PACKED_BYTE, "11111000111111001111111011111111"),
        (C_ALU_EBF,  "10001111100001111000001110000001", ctrl8(3,4, 0,5, 0,6, 0,7), C_PACKED_BYTE, "00000000111111001111111011111111"),

        -- EBFU
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,0), C_PACKED_NONE, "10001111000001110000001100000001"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,1), C_PACKED_NONE, "01000111100000111000000110000000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,2), C_PACKED_NONE, "00100011110000011100000011000000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,3), C_PACKED_NONE, "00010001111000001110000001100000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,4), C_PACKED_NONE, "00001000111100000111000000110000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,5), C_PACKED_NONE, "00000100011110000011100000011000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,6), C_PACKED_NONE, "00000010001111000001110000001100"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,7), C_PACKED_NONE, "00000001000111100000111000000110"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,8), C_PACKED_NONE, "00000000100011110000011100000011"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,9), C_PACKED_NONE, "00000000010001111000001110000001"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,10), C_PACKED_NONE, "00000000001000111100000111000000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,11), C_PACKED_NONE, "00000000000100011110000011100000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,12), C_PACKED_NONE, "00000000000010001111000001110000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,13), C_PACKED_NONE, "00000000000001000111100000111000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,14), C_PACKED_NONE, "00000000000000100011110000011100"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,15), C_PACKED_NONE, "00000000000000010001111000001110"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,16), C_PACKED_NONE, "00000000000000001000111100000111"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,17), C_PACKED_NONE, "00000000000000000100011110000011"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,18), C_PACKED_NONE, "00000000000000000010001111000001"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,19), C_PACKED_NONE, "00000000000000000001000111100000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,20), C_PACKED_NONE, "00000000000000000000100011110000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,21), C_PACKED_NONE, "00000000000000000000010001111000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,22), C_PACKED_NONE, "00000000000000000000001000111100"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,23), C_PACKED_NONE, "00000000000000000000000100011110"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,24), C_PACKED_NONE, "00000000000000000000000010001111"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,25), C_PACKED_NONE, "00000000000000000000000001000111"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,26), C_PACKED_NONE, "00000000000000000000000000100011"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,27), C_PACKED_NONE, "00000000000000000000000000010001"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,28), C_PACKED_NONE, "00000000000000000000000000001000"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,29), C_PACKED_NONE, "00000000000000000000000000000100"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,30), C_PACKED_NONE, "00000000000000000000000000000010"),
        (C_ALU_EBFU, "10001111000001110000001100000001", ctrl32(0,31), C_PACKED_NONE, "00000000000000000000000000000001"),

        (C_ALU_EBFU, "10001111000001111000001100000001", ctrl16(0,0, 0,1), C_PACKED_HALF_WORD, "10001111000001110100000110000000"),
        (C_ALU_EBFU, "10001111000001111000001100000001", ctrl16(0,2, 0,3), C_PACKED_HALF_WORD, "00100011110000010001000001100000"),
        (C_ALU_EBFU, "10001111000001111000001100000001", ctrl16(0,4, 0,5), C_PACKED_HALF_WORD, "00001000111100000000010000011000"),
        (C_ALU_EBFU, "10001111000001111000001100000001", ctrl16(0,6, 0,7), C_PACKED_HALF_WORD, "00000010001111000000000100000110"),
        (C_ALU_EBFU, "10001111000001111000001100000001", ctrl16(0,8, 0,9), C_PACKED_HALF_WORD, "00000000100011110000000001000001"),
        (C_ALU_EBFU, "10001111000001111000001100000001", ctrl16(0,10, 0,11), C_PACKED_HALF_WORD, "00000000001000110000000000010000"),
        (C_ALU_EBFU, "10001111000001111000001100000001", ctrl16(0,12, 0,13), C_PACKED_HALF_WORD, "00000000000010000000000000000100"),
        (C_ALU_EBFU, "10001111000001111000001100000001", ctrl16(0,14, 0,15), C_PACKED_HALF_WORD, "00000000000000100000000000000001"),

        (C_ALU_EBFU, "10001111100001111000001110000001", ctrl8(0,0, 0,1, 0,2, 0,3), C_PACKED_BYTE, "10001111010000110010000000010000"),
        (C_ALU_EBFU, "10001111100001111000001110000001", ctrl8(0,4, 0,5, 0,6, 0,7), C_PACKED_BYTE, "00001000000001000000001000000001"),

        -- MKBF
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,0), C_PACKED_NONE, "10001111000001110000001100000001"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,1), C_PACKED_NONE, "00011110000011100000011000000010"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,2), C_PACKED_NONE, "00111100000111000000110000000100"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,3), C_PACKED_NONE, "01111000001110000001100000001000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,4), C_PACKED_NONE, "11110000011100000011000000010000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,5), C_PACKED_NONE, "11100000111000000110000000100000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,6), C_PACKED_NONE, "11000001110000001100000001000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,7), C_PACKED_NONE, "10000011100000011000000010000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,8), C_PACKED_NONE, "00000111000000110000000100000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,9), C_PACKED_NONE, "00001110000001100000001000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,10), C_PACKED_NONE, "00011100000011000000010000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,11), C_PACKED_NONE, "00111000000110000000100000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,12), C_PACKED_NONE, "01110000001100000001000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,13), C_PACKED_NONE, "11100000011000000010000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,14), C_PACKED_NONE, "11000000110000000100000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,15), C_PACKED_NONE, "10000001100000001000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,16), C_PACKED_NONE, "00000011000000010000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,17), C_PACKED_NONE, "00000110000000100000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,18), C_PACKED_NONE, "00001100000001000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,19), C_PACKED_NONE, "00011000000010000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,20), C_PACKED_NONE, "00110000000100000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,21), C_PACKED_NONE, "01100000001000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,22), C_PACKED_NONE, "11000000010000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,23), C_PACKED_NONE, "10000000100000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,24), C_PACKED_NONE, "00000001000000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,25), C_PACKED_NONE, "00000010000000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,26), C_PACKED_NONE, "00000100000000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,27), C_PACKED_NONE, "00001000000000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,28), C_PACKED_NONE, "00010000000000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,29), C_PACKED_NONE, "00100000000000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,30), C_PACKED_NONE, "01000000000000000000000000000000"),
        (C_ALU_MKBF, "10001111000001110000001100000001", ctrl32(0,31), C_PACKED_NONE, "10000000000000000000000000000000"),

        (C_ALU_MKBF, "10001111000001111000001100000001", ctrl16(0,0, 0,1), C_PACKED_HALF_WORD, "10001111000001110000011000000010"),
        (C_ALU_MKBF, "10001111000001111000001100000001", ctrl16(0,2, 0,3), C_PACKED_HALF_WORD, "00111100000111000001100000001000"),
        (C_ALU_MKBF, "10001111000001111000001100000001", ctrl16(0,4, 0,5), C_PACKED_HALF_WORD, "11110000011100000110000000100000"),
        (C_ALU_MKBF, "10001111000001111000001100000001", ctrl16(0,6, 0,7), C_PACKED_HALF_WORD, "11000001110000001000000010000000"),
        (C_ALU_MKBF, "10001111000001111000001100000001", ctrl16(0,8, 0,9), C_PACKED_HALF_WORD, "00000111000000000000001000000000"),
        (C_ALU_MKBF, "10001111000001111000001100000001", ctrl16(0,10, 0,11), C_PACKED_HALF_WORD, "00011100000000000000100000000000"),
        (C_ALU_MKBF, "10001111000001111000001100000001", ctrl16(0,12, 0,13), C_PACKED_HALF_WORD, "01110000000000000010000000000000"),
        (C_ALU_MKBF, "10001111000001111000001100000001", ctrl16(0,14, 0,15), C_PACKED_HALF_WORD, "11000000000000001000000000000000"),

        (C_ALU_MKBF, "10001111100001111000001110000001", ctrl8(0,0, 0,1, 0,2, 0,3), C_PACKED_BYTE, "10001111000011100000110000001000"),
        (C_ALU_MKBF, "10001111100001111000001110000001", ctrl8(0,4, 0,5, 0,6, 0,7), C_PACKED_BYTE, "11110000111000001100000010000000")
      );
  begin
    -- Test all the patterns in the pattern array.
    for i in patterns'range loop
      --  Set the inputs.
      s_op <= patterns(i).op;
      s_src <= patterns(i).src;
      s_dst <= (others => '0');  -- TODO(m): Add tests for this too.
      s_ctrl <= patterns(i).ctrl;
      s_packed_mode <= patterns(i).packed_mode;

      --  Wait for the results.
      wait for 1 ns;

      --  Check the outputs.
      assert s_result = patterns(i).result
        report "Bad result:" & lf &
               "  op=" & to_string(s_op) & " ctrl=" & to_string(s_ctrl) & " pm=" & to_string(s_packed_mode) & lf &
               "  src=" & to_string(s_src) & lf &
               "  res=" & to_string(s_result) & lf &
               " (exp=" & to_string(patterns(i).result) & ")"
          severity error;
    end loop;
    assert false report "End of test" severity note;
    --  Wait forever; this will finish the simulation.
    wait;
  end process;
end behavioral;

