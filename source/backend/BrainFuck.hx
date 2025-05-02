package backend;

import haxe.ds.IntMap;

class BrainfuckError extends haxe.Exception {
    public function new(message: String) {
        super(message);
    }
}

class BrainFuck {
    private static inline var VALID_COMMANDS = "><+-.,[]";
    
    public static function runBrainfuck(code: String, input: Map<Int, Int>): String {
        // Pre-filter code to only valid commands for better performance
        var filteredCode = code.split("").filter(char -> VALID_COMMANDS.indexOf(char) != -1).join("");
        
        // Initialize data structures
        var tape = [0];
        var tapePointer = 0;
        var codePointer = 0;
        var index = 0;
        var output = new StringBuf();
        var bracketMap = validateAndMapBrackets(filteredCode);

        // Main execution loop
        while (codePointer < filteredCode.length) {
            switch (filteredCode.charAt(codePointer)) {
                case '>':
                    tapePointer++;
                    if (tapePointer >= tape.length) tape.push(0);
                    
                case '<':
                    tapePointer = Std.int(Math.max(0, tapePointer - 1));
                    
                case '+':
                    tape[tapePointer] = (tape[tapePointer] + 1) & 0xFF;
                    
                case '-':
                    tape[tapePointer] = (tape[tapePointer] - 1) & 0xFF;
                    
                case '.':
                    var charCode = tape[tapePointer];
                    output.add((charCode >= 0 && charCode <= 127) ? 
                        String.fromCharCode(charCode) : "?");
                    
                case ',':
                    if (input.exists(index)) {
                        tape[tapePointer] = input.get(index);
                        index++;
                    } else {
                        tape[tapePointer] = 0;
                    }
                    
                case '[':
                    if (tape[tapePointer] == 0)
                        codePointer = bracketMap.get(codePointer);
                        
                case ']':
                    if (tape[tapePointer] != 0)
                        codePointer = bracketMap.get(codePointer) - 1;
            }
            codePointer++;
        }

        return output.toString();
    }

    private static function validateAndMapBrackets(code: String): IntMap<Int> {
        var bracketMap = new IntMap<Int>();
        var positions = new Array<Int>();
        var openBrackets = 0;

        for (i in 0...code.length) {
            switch (code.charAt(i)) {
                case '[':
                    openBrackets++;
                    positions.push(i);
                    
                case ']':
                    if (openBrackets == 0) 
                        throw new BrainfuckError('Unmatched closing bracket at position $i');
                    openBrackets--;
                    var openPos = positions.pop();
                    bracketMap.set(openPos, i);
                    bracketMap.set(i, openPos);
            }
        }
        
        if (openBrackets != 0)
            throw new BrainfuckError("Unmatched opening bracket");
            
        return bracketMap;
    }
}
