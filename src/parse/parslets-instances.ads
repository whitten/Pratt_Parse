Pragma Ada_2012;
Pragma Assertion_Policy( Check );

With
Parser_Precedence;

Use
Parser_Precedence;

Package Parslets.Instances is

   -------------------
   --  COMPILATION  --
   -------------------

    Type Compilation_Unit is new Prefix with null record;
--      context_clause library_item
--  | context_clause subunit


   -------------------
   --  EXPRESSIONS  --
   -------------------

   Type Assign is new Infix with null Record;

   -- When handling right-associative operators like "**", we need a slightly
   -- lower precedence for parsing the right-hand side. This will let a parselet
   -- with the same precedence appear on the right, which will then take the
   -- result of this parselet as its own left-hand argument.
   Type Binary_Operator(Precedence_Value : Natural;
                        Is_Right         : Boolean
                       ) is new Infix with null Record;

   Type Call_Parameters is new Infix with null Record;

   Type Grouping_Parens is new Prefix with null Record;

   Type Name is new Prefix with null Record;


Private

   -----------------------
   --  PARSE FUNCTIONS  --
   -----------------------

   Function Parse(Item   : in     Assign;
                  Parser : in out Parslets.Parser;
                  Left   : in     PE.Expression'Class;
                  Token  : in     Aux.Token
                 ) return PE.Expression'Class;

   Function Parse(Item   : in     Binary_Operator;
                  Parser : in out Parslets.Parser;
                  Left   : in     PE.Expression'Class;
                  Token  : in     Aux.Token
                 ) return PE.Expression'Class;

   Function Parse(Item   : in     Call_Parameters;
                  Parser : in out Parslets.Parser;
                  Left   : in     PE.Expression'Class;
                  Token  : in     Aux.Token
                 ) return PE.Expression'Class;

   Function Parse(Item   : in     Grouping_Parens;
                  Parser : in out Parslets.Parser;
                  Token  : in     Aux.Token
                 ) return PE.Expression'Class;

   Function Parse(Item   : in     Name;
                  Parser : in out Parslets.Parser;
                  Token  : in     Aux.Token
                 ) return PE.Expression'Class;

   Function Parse(Item   : in     Compilation_Unit;
                  Parser : in out Parslets.Parser;
                  Token  : in     Aux.Token
                 ) return PE.Expression'Class;

   ------------------
   --  PRECEDENCE  --
   ------------------

    Function Precedence(Item : Assign) return Natural           is (ASSIGNMENT);
    Function Precedence(Item : Binary_Operator) return Natural  is (Item.Precedence_Value);
    Function Precedence(Item : Call_Parameters) return Natural  is (CALL);
    Function Precedence(Item : Grouping_Parens) return Natural  is (Parser_Precedence.PREFIX);
    Function Precedence(Item : Name) return Natural             is (Parser_Precedence.PREFIX);
    Function Precedence(Item : Compilation_Unit) return Natural is (9999);

   ----------------------
   --  UTIL FUNCTIONS  --
   ----------------------

   Function ID (Input : Aux.Token) return Aux.Token_ID renames Aux.Token_Pkg.ID;
   Function "-"(Input : Aux.Token) return Wide_Wide_String renames Aux.Token_Pkg.Lexeme;
   Function "-"(Input : Aux.Token) return not null access Wide_Wide_String is
      ( new Wide_Wide_String'(-Input) );


   ----------------------
   --  INIT FUNCTIONS  --
   ----------------------

    Function Init return Assign           is (null record);
    Function Init return Binary_Operator  is (2,True);
    Function Init return Call_Parameters  is (null record);
    Function Init return Grouping_Parens  is (null record);
    Function Init return Name             is (null record);
    Function Init return Compilation_Unit is (null record);

   ------------------------
   --  CREATE FUNCTIONS  --
   ------------------------

   Function Create( Parser : not null access Parslets.Parser ) return Assign;
   Function Create( Parser : not null access Parslets.Parser ) return Binary_Operator;
   Function Create( Parser : not null access Parslets.Parser ) return Call_Parameters;
   Function Create( Parser : not null access Parslets.Parser ) return Grouping_Parens;
   Function Create( Parser : not null access Parslets.Parser ) return Name;
   Function Create( Parser : not null access Parslets.Parser ) return Compilation_Unit;
End Parslets.Instances;
