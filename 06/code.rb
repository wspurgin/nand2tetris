class AssemblerCodeException < Exception; end

class Code

  @@dest = {
            nil   =>   0,
            'M'   =>   1,
            'D'   =>   2,
            'MD'  =>   3,
            'A'   =>   4,
            'AM'  =>   5,
            'AD'  =>   6,
            'AMD' =>   7
           }

  @@jump = {
            nil   =>   0,
            'JGT' =>   1,
            'JEQ' =>   2,
            'JGE' =>   3,
            'JLT' =>   4,
            'JNE' =>   5,
            'JLE' =>   6,
            'JMP' =>   7
           }

  @@comp = {
            '0'   =>  42,
            '1'   =>  63,
            '-1'  =>  58,
            'D'   =>  12,
            'A'   =>  48,
            '!D'  =>  13,
            '!A'  =>  49,
            '-D'  =>  15,
            '-A'  =>  51,
            'D+1' =>  31,
            'A+1' =>  55,
            'D-1' =>  14,
            'A-1' =>  50,
            'D+A' =>   2,
            'D-A' =>  19,
            'A-D' =>   7,
            'D&A' =>   0,
            'D|A' =>  21,
            'M'   => 112,
            '!M'  => 113,
            '-M'  => 115,
            'M+1' => 119,
            'M-1' => 114,
            'D+M' =>  66,
            'D-M' =>  83,
            'M-D' =>  71,
            'D&M' =>  64,
            'D|M' =>  85
           }

  def constant(m)
    "%015b" % m
  end

  # Returns the 3-bit binary code of the dest mnemonic
  def dest(m)
    validate(@@dest, m)
    "%03b" % @@dest[m]
  end

  # Returns the 7-bit binary code of the comp mnemonic
  def comp(m)
    validate(@@comp, m)
    "%07b" % @@comp[m]
  end

  # Returns the 3-bit binary code of the jump mnemonic
  def jump(m)
    validate(@@jump, m)
    "%03b" % @@jump[m]
  end

  # Checks to see if the mnemonic is defined in the relevant hash table
  def validate(mnemonic_table, mnemonic)
    raise AssemblerCodeException.new("Symbol #{mnemonic} invalid") unless mnemonic_table.include?(mnemonic)
  end

end