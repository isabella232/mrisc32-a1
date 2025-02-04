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
use ieee.numeric_std.all;
use work.config.all;

package types is
  ------------------------------------------------------------------------------------------------
  -- Branch types (used by branch predictor and branch logic).
  ------------------------------------------------------------------------------------------------

  subtype T_BRANCH_TYPE is std_logic_vector(1 downto 0);
  constant C_BRANCH_NONE : T_BRANCH_TYPE := "00";
  constant C_BRANCH_JUMP : T_BRANCH_TYPE := "01";  -- Conditional & unconditional jumps.
  constant C_BRANCH_CALL : T_BRANCH_TYPE := "10";  -- Subroutine call.
  constant C_BRANCH_RET  : T_BRANCH_TYPE := "11";  -- Subroutine return.

  ------------------------------------------------------------------------------------------------
  -- Source and target register meta data.
  ------------------------------------------------------------------------------------------------

  type T_SRC_REG is record
    reg : std_logic_vector(C_LOG2_NUM_REGS-1 downto 0);
    element : std_logic_vector(C_LOG2_VEC_REG_ELEMENTS-1 downto 0);
    is_vector : std_logic;
  end record T_SRC_REG;

  type T_DST_REG is record
    is_target : std_logic;  -- '1' if the register is being written to, otherwise '0'.
    reg : std_logic_vector(C_LOG2_NUM_REGS-1 downto 0);
    element : std_logic_vector(C_LOG2_VEC_REG_ELEMENTS-1 downto 0);
    is_vector : std_logic;
  end record T_DST_REG;


  ------------------------------------------------------------------------------------------------
  -- Source operand modes.
  ------------------------------------------------------------------------------------------------

  subtype T_SRC_A_MODE is std_logic_vector(0 downto 0);
  constant C_SRC_A_REG : T_SRC_A_MODE := "0";
  constant C_SRC_A_PC : T_SRC_A_MODE := "1";

  subtype T_SRC_B_MODE is std_logic_vector(0 downto 0);
  constant C_SRC_B_REG : T_SRC_B_MODE := "0";
  constant C_SRC_B_IMM : T_SRC_B_MODE := "1";

  subtype T_SRC_C_MODE is std_logic_vector(0 downto 0);
  constant C_SRC_C_REG : T_SRC_C_MODE := "0";
  constant C_SRC_C_PC : T_SRC_C_MODE := "1";


  ------------------------------------------------------------------------------------------------
  -- Packed opertaion modes.
  ------------------------------------------------------------------------------------------------

  subtype T_PACKED_MODE is std_logic_vector(1 downto 0);
  constant C_PACKED_NONE : T_PACKED_MODE      := "00";
  constant C_PACKED_BYTE : T_PACKED_MODE      := "01";
  constant C_PACKED_HALF_WORD : T_PACKED_MODE := "10";


  ------------------------------------------------------------------------------------------------
  -- Operation identifiers
  ------------------------------------------------------------------------------------------------

  -- Branch conditions.
  constant C_BRANCH_COND_SIZE : integer := 3;
  subtype T_BRANCH_COND is std_logic_vector(C_BRANCH_COND_SIZE-1 downto 0);
  constant C_BRANCH_BZ : T_BRANCH_COND := "000";
  constant C_BRANCH_NZ : T_BRANCH_COND := "001";
  constant C_BRANCH_S  : T_BRANCH_COND := "010";
  constant C_BRANCH_NS : T_BRANCH_COND := "011";
  constant C_BRANCH_LT : T_BRANCH_COND := "100";
  constant C_BRANCH_GE : T_BRANCH_COND := "101";
  constant C_BRANCH_LE : T_BRANCH_COND := "110";
  constant C_BRANCH_GT : T_BRANCH_COND := "111";

  -- ALU operations.
  constant C_ALU_OP_SIZE : integer := 6;
  subtype T_ALU_OP is std_logic_vector(C_ALU_OP_SIZE-1 downto 0);

  constant C_ALU_LDI    : T_ALU_OP := "000001";

  constant C_ALU_REV    : T_ALU_OP := "001000";  -- Two-operand (op=0x7c, func=0x00)
  constant C_ALU_CLZ    : T_ALU_OP := "001001";  -- Two-operand (op=0x7c, func=0x01)
  constant C_ALU_POPCNT : T_ALU_OP := "001010";  -- Two-operand (op=0x7c, func=0x02)

  constant C_ALU_AND    : T_ALU_OP := "010000";
  constant C_ALU_OR     : T_ALU_OP := "010001";
  constant C_ALU_XOR    : T_ALU_OP := "010010";

  constant C_ALU_EBF    : T_ALU_OP := "010011";
  constant C_ALU_EBFU   : T_ALU_OP := "010100";
  constant C_ALU_MKBF   : T_ALU_OP := "010101";

  constant C_ALU_ADD    : T_ALU_OP := "010110";
  constant C_ALU_SUB    : T_ALU_OP := "010111";

  constant C_ALU_MIN    : T_ALU_OP := "011000";
  constant C_ALU_MAX    : T_ALU_OP := "011001";
  constant C_ALU_MINU   : T_ALU_OP := "011010";
  constant C_ALU_MAXU   : T_ALU_OP := "011011";

  constant C_ALU_SEQ    : T_ALU_OP := "011100";
  constant C_ALU_SNE    : T_ALU_OP := "011101";
  constant C_ALU_SLT    : T_ALU_OP := "011110";
  constant C_ALU_SLTU   : T_ALU_OP := "011111";
  constant C_ALU_SLE    : T_ALU_OP := "100000";
  constant C_ALU_SLEU   : T_ALU_OP := "100001";

  constant C_ALU_SHUF   : T_ALU_OP := "100010";
  constant C_ALU_XCHGSR : T_ALU_OP := "100100";

  constant C_ALU_SEL    : T_ALU_OP := "101110";
  constant C_ALU_IBF    : T_ALU_OP := "101111";

  constant C_ALU_PACK     : T_ALU_OP := "111010";
  constant C_ALU_PACKS    : T_ALU_OP := "111011";
  constant C_ALU_PACKSU   : T_ALU_OP := "111100";
  constant C_ALU_PACKHI   : T_ALU_OP := "111101";
  constant C_ALU_PACKHIR  : T_ALU_OP := "111110";
  constant C_ALU_PACKHIUR : T_ALU_OP := "111111";

  -- DIV operations.
  constant C_DIV_OP_SIZE : integer := 3;
  subtype T_DIV_OP is std_logic_vector(C_DIV_OP_SIZE-1 downto 0);

  constant C_DIV_DIV  : T_DIV_OP := "000";
  constant C_DIV_DIVU : T_DIV_OP := "001";
  constant C_DIV_REM  : T_DIV_OP := "010";
  constant C_DIV_REMU : T_DIV_OP := "011";
  constant C_DIV_FDIV : T_DIV_OP := "100";  -- Special decoding.

  -- MUL operations.
  constant C_MUL_OP_SIZE : integer := 3;
  subtype T_MUL_OP is std_logic_vector(C_MUL_OP_SIZE-1 downto 0);

  constant C_MUL_MUL    : T_MUL_OP := "111";
  constant C_MUL_MADD   : T_MUL_OP := "100";
  constant C_MUL_MULHI  : T_MUL_OP := "000";
  constant C_MUL_MULHIU : T_MUL_OP := "001";
  constant C_MUL_MULQ   : T_MUL_OP := "010";
  constant C_MUL_MULQR  : T_MUL_OP := "011";

  -- FPU operations.
  constant C_FPU_OP_SIZE : integer := 6;
  subtype T_FPU_OP is std_logic_vector(C_FPU_OP_SIZE-1 downto 0);

  constant C_FPU_FMIN    : T_FPU_OP := "000000";
  constant C_FPU_FMAX    : T_FPU_OP := "000001";
  constant C_FPU_FSEQ    : T_FPU_OP := "000010";
  constant C_FPU_FSNE    : T_FPU_OP := "000011";
  constant C_FPU_FSLT    : T_FPU_OP := "000100";
  constant C_FPU_FSLE    : T_FPU_OP := "000101";
  constant C_FPU_FSUNORD : T_FPU_OP := "000110";
  constant C_FPU_FSORD   : T_FPU_OP := "000111";

  constant C_FPU_ITOF    : T_FPU_OP := "001000";
  constant C_FPU_UTOF    : T_FPU_OP := "001001";
  constant C_FPU_FTOI    : T_FPU_OP := "001010";
  constant C_FPU_FTOU    : T_FPU_OP := "001011";
  constant C_FPU_FTOIR   : T_FPU_OP := "001100";
  constant C_FPU_FTOUR   : T_FPU_OP := "001101";
  constant C_FPU_FPACK   : T_FPU_OP := "001110";

  constant C_FPU_FADD    : T_FPU_OP := "010000";
  constant C_FPU_FSUB    : T_FPU_OP := "010001";
  constant C_FPU_FMUL    : T_FPU_OP := "010010";
  constant C_FPU_FDIV    : T_FPU_OP := "010011";  -- Not handled by the FPU!

  constant C_FPU_FUNPL   : T_FPU_OP := "100000";  -- Two-operand (op=0x7d, func=0x00)
  constant C_FPU_FUNPH   : T_FPU_OP := "100001";  -- Two-operand (op=0x7d, func=0x01)

  -- SAU operations.
  constant C_SAU_OP_SIZE : integer := 4;
  subtype T_SAU_OP is std_logic_vector(C_SAU_OP_SIZE-1 downto 0);

  constant C_SAU_ADDS   : T_SAU_OP := "0000";
  constant C_SAU_ADDSU  : T_SAU_OP := "0001";
  constant C_SAU_ADDH   : T_SAU_OP := "0010";
  constant C_SAU_ADDHU  : T_SAU_OP := "0011";
  constant C_SAU_ADDHR  : T_SAU_OP := "0100";
  constant C_SAU_ADDHUR : T_SAU_OP := "0101";
  constant C_SAU_SUBS   : T_SAU_OP := "0110";
  constant C_SAU_SUBSU  : T_SAU_OP := "0111";
  constant C_SAU_SUBH   : T_SAU_OP := "1000";
  constant C_SAU_SUBHU  : T_SAU_OP := "1001";
  constant C_SAU_SUBHR  : T_SAU_OP := "1010";
  constant C_SAU_SUBHUR : T_SAU_OP := "1011";

  -- MEM operations.
  constant C_MEM_OP_SIZE : integer := 4;
  subtype T_MEM_OP is std_logic_vector(C_MEM_OP_SIZE-1 downto 0);

  -- The memory operation is encoded as follows: "SUWW", where:
  --   S  = Store    (1 = store, 0 = load).
  --   U  = Unsigned (1 = unsigned, 0 = signed)
  --   WW = Width    (01 = byte, 10 = halfword, 11 = word)
  constant C_MEM_OP_NONE    : T_MEM_OP := "0000";
  constant C_MEM_OP_LOAD8   : T_MEM_OP := "0001";
  constant C_MEM_OP_LOAD16  : T_MEM_OP := "0010";
  constant C_MEM_OP_LOAD32  : T_MEM_OP := "0011";
  constant C_MEM_OP_LOADU8  : T_MEM_OP := "0101";
  constant C_MEM_OP_LOADU16 : T_MEM_OP := "0110";
  constant C_MEM_OP_LDEA    : T_MEM_OP := "0111";
  constant C_MEM_OP_STORE8  : T_MEM_OP := "1001";
  constant C_MEM_OP_STORE16 : T_MEM_OP := "1010";
  constant C_MEM_OP_STORE32 : T_MEM_OP := "1011";

  ------------------------------------------------------------------------------------------------
  -- Floating point configurations.
  ------------------------------------------------------------------------------------------------

  -- Floating point configurations.
  constant F32_WIDTH : positive := 32;
  constant F32_EXP_BITS : positive := 8;
  constant F32_EXP_BIAS : positive := 127;
  constant F32_FRACT_BITS : positive := F32_WIDTH - 1 - F32_EXP_BITS;

  constant F16_WIDTH : positive := 16;
  constant F16_EXP_BITS : positive := 5;
  constant F16_EXP_BIAS : positive := 15;
  constant F16_FRACT_BITS : positive := F16_WIDTH - 1 - F16_EXP_BITS;

  constant F8_WIDTH : positive := 8;
  constant F8_EXP_BITS : positive := 4;
  constant F8_EXP_BIAS : positive := 7;
  constant F8_FRACT_BITS : positive := F8_WIDTH - 1 - F8_EXP_BITS;

  -- Floating point value properties.
  type T_FLOAT_PROPS is record
    is_neg : std_logic;
    is_nan : std_logic;
    is_inf : std_logic;
    is_zero : std_logic;
  end record T_FLOAT_PROPS;

  ------------------------------------------------------------------------------------------------
  -- Helper functions
  ------------------------------------------------------------------------------------------------

  function to_vector(x: integer; size: integer) return std_logic_vector;
  function to_word(x: integer) return std_logic_vector;
  function to_std_logic(x: boolean) return std_logic;
  function to_string(x: std_logic_vector) return string;
  function to_string(x: std_logic) return string;
  function is_zero(x: std_logic_vector) return std_logic;
  function log2(x: integer) return integer;

end package;

package body types is
  function to_vector(x: integer; size: integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(x, size));
  end function;

  function to_word(x: integer) return std_logic_vector is
  begin
    return to_vector(x, C_WORD_SIZE);
  end function;

  function to_std_logic(x: boolean) return std_logic is
  begin
    if x then
      return '1';
    else
      return '0';
    end if;
  end function;

  function to_string(x: std_logic_vector) return string is
    variable v_b : string (1 to x'length) := (others => NUL);
    variable v_stri : integer := 1;
  begin
    for i in x'range loop
      v_b(v_stri) := std_logic'image(x((i)))(2);
      v_stri := v_stri+1;
    end loop;
    return v_b;
  end function;

  function to_string(x: std_logic) return string is
  begin
    return std_logic'image(x);
  end function;

  function is_zero(x: std_logic_vector) return std_logic is
    constant ALL_ZEROS : std_logic_vector(x'range) := (others => '0');
  begin
    if x = ALL_ZEROS then
      return '1';
    else
      return '0';
    end if;
  end function;

  -- The log2() function computes y = floor(log2(x)). For example:
  --   log2(0) -> -1
  --   log2(1) -> 0
  --   log2(2) -> 1
  --   log2(3) -> 1
  --   log2(4) -> 2
  --   log2(255) -> 7
  --   log2(256) -> 8
  --
  -- To calculate the number of required bits to represent a number in the range [0, N]:
  --   bits_required = log2(N)+1;
  --
  -- For example, to index any bit in a 24-bit word, [0, 23], bits_required = log2(24-1)+1 = 5
  --
  -- Note: Do not use this for synthesis, only for constants!
  function log2(x: integer) return integer is
    variable v_temp : integer;
    variable v_log : integer;
  begin
    v_temp := x;
    v_log := -1;
    while v_temp /= 0 loop
      v_temp := v_temp / 2;
      v_log := v_log + 1;
    end loop;
    return v_log;
  end function;
end package body;
