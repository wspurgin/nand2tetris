class AssemblerSymbolTableException < Exception; end

class SymbolTable

  # Creates a new, empty symbol table
  def initialize
    @@symbol_table = {
      'SP' => 0,
      'LCL' => 1,
      'ARG' => 2,
      'THIS' => 3,
      'THAT' => 4,
      'R0' => 0,
      'R1' => 1,
      'R2' => 2,
      'R3' => 3,
      'R4' => 4,
      'R5' => 5,
      'R6' => 6,
      'R7' => 7,
      'R8' => 8,
      'R9' => 9,
      'R10' => 10,
      'R11' => 11,
      'R12' => 12,
      'R13' => 13,
      'R14' => 14,
      'R15' => 15,
      'SCREEN' => 16384,
      'KBD' => 24576
    }

    @next_address = 16
    @@max_address = @@symbol_table['SCREEN'];
  end

  # Adds the pairs (symbol, address) to the symbol table
  def add_entry(symbol, address)
    @@symbol_table[symbol] = address
  end

  # Does the symbol table contain the given symbol?
  def contains?(symbol)
    return @@symbol_table.include?(symbol)
  end

  # Returns the addres associated with the symbol
  def address_of(symbol)
    if not self.contains?(symbol)
      unless @next_address == @@max_address
        add_entry(symbol, @next_address)
        @next_address += 1
      else
        raise AssemblerSymbolTableException("Overflow. Attempting to write into reserved space");
      end
    end
    return @@symbol_table[symbol]
  end

end