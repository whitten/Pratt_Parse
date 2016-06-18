Pragma Ada_2012;
Pragma Assertion_Policy( Check );

With
-- FOR DEBUGGING
Ada.Wide_Wide_Text_IO,
-- END DEBUGGING
Ada.Tags,
Ada.Containers.Indefinite_Vectors,
Ada.Containers.Indefinite_Ordered_Maps,
Expressions,
Lexington.Token_Vector_Pkg,
Lexington.Aux;

Package Parslets is
   package PE  renames Expressions;
   package Aux renames Lexington.Aux;

   type Parser;

   Type Infix is interface;
   Function Parse(Item   : in     Infix;
                  Parser : in out Parslets.Parser;
                  Left   : in     PE.Expression'Class;
                  Token  : in     Aux.Token
                 ) return PE.Expression'Class is abstract;
--     Function Parse(Item   : Infix;
--                    Parser : in out parslets.Parser;
--                    Left   : in PE.Expression'Class;
--                    Token  : in Lexington.Aux.Token) return PE.Expression'Class is abstract;
   Function Precedence(Item   : Infix) return Natural is abstract;
   Function Create( Parser : not null access Parslets.Parser ) return Infix is abstract;
   Function Init return Infix is abstract;

   Type Prefix is interface;
   Function Parse(Item   : in     Prefix;
                  Parser : in out Parslets.Parser;
                  Token  : in     Aux.Token
                 ) return PE.Expression'Class is abstract;
   Function Precedence(Item   : Prefix) return Natural is abstract;
   Function Create( Parser : not null access Parslets.Parser ) return Prefix is abstract;
   Function Init return Prefix is abstract;

   --------------------
   -- PARSER METHODS --
   --------------------

--     Procedure Register( Parser : in out Parslets.Parser;
--                         Token  : in     Aux.Token_ID;
--                         Prefix : in     Parslets.Prefix'Class
--                       );
--
--     Procedure Register( Parser : in out Parslets.Parser;
--                         Token  : in     Aux.Token_ID;
--                         Infix  : in     Parslets.Infix'Class
--                       );

   Procedure Register( Parser : in out Parslets.Parser;
                       Token  : in     Aux.Token_ID;
                       Tag    : in     Ada.Tags.Tag;
                       Infix  : in     Boolean
                     );

   Function Create( Parser : in out Parslets.Parser;
                    Tag    : in     Ada.Tags.Tag
                  ) return Infix'Class;

   Function Create( Parser : in out Parslets.Parser;
                    Tag    : in     Ada.Tags.Tag
                  ) return Prefix'Class;

   Function Parse( Parser     : in out Parslets.Parser;
                   Precedence : in Natural := 0
                 ) return PE.Expression'Class;

   Function Consume(Parser   : in out Parslets.Parser;
                    Expected : in     Aux.Token_ID
                   ) Return Aux.Token;

   Function Consume(Parser   : in out Parslets.Parser
                   ) Return Aux.Token;

   Procedure Look_Ahead(Parser   : in out Parslets.Parser;
                        Distance : Natural
                       );

   Function Look_Ahead(Parser   : in out Parslets.Parser;
                       Distance : Natural
                      ) return Aux.Token;

   Function Look_Ahead(Parser   : in out Parslets.Parser;
                       Distance : Natural
                      ) return Aux.Token_ID;

   Function Precedence(Parser   : in out Parslets.Parser) return Natural;

   Function Match(Parser   : in out Parslets.Parser;
                  Expected : in     Aux.Token_ID
                 ) return Boolean;

   Function Look_Behind(Parser : in Parslets.Parser) return PE.Expression'Class;

   Function Create(Tokens : aliased Lexington.Token_Vector_Pkg.Vector) return Parser;
   type Parser(<>) is private;

Private
    use type Ada.Tags.Tag;

    Type NNAC_Token_Vector is not null access constant Lexington.Token_Vector_Pkg.Vector;

   package Infix_Map is new Ada.Containers.Indefinite_Ordered_Maps(
      "<"          => Aux."<",
      Key_Type     => Aux.Token_ID,
      Element_Type => Ada.Tags.Tag
     );

   package Prefix_Map is new Ada.Containers.Indefinite_Ordered_Maps(
      "<"          => Aux."<",
      Key_Type     => Aux.Token_ID,
      Element_Type => Ada.Tags.Tag
     );

--     package Token_Vector is new Ada.Containers.Indefinite_Vectors(
--        "="          => Aux.Token_Pkg."=",
--        Index_Type   => Positive,
--        Element_Type => Aux.Token
--       );

    Type Stream_Cursor is record
	Stream_Ptr : NNAC_Token_Vector;
	Position   : Natural;--:= Natural'Pred( Stream_Cursor.Stream.First_Index );
   end record;

   Function Next_Token(Input : in out Stream_Cursor) return Aux.Token;

   type Parser(Stream : NNAC_Token_Vector) is record
      Infix_Parslets  : Infix_Map.Map;
      Prefix_Parslets : Prefix_Map.Map;
      Buffer          : Lexington.Token_Vector_Pkg.Vector;-- Token_Vector.Vector;
      Token_Stream    : Stream_Cursor:= (Stream_Ptr => Stream, Position => Natural'Pred( Stream.First_Index ));
   end record;

-- This must be moved to the body for the program to be compiled; even though
-- the full implementation of a function is allowed if it is an expression-
-- function like this. The error it gives is that the Parser at line 16 is
-- expected, but the Parser at line 131 is found.
--     Function Create(Tokens : aliased Lexington.Token_Vector_Pkg.Vector) return Parser is
--       ( Stream => Tokens'Access, others => <> );

      Type Temp is new PE.Expression with null Record;
      Function Print(Item : Temp;
                     Level  : Ada.Containers.Count_Type := 0
                    ) return Wide_Wide_String is
        ("[NULL RECORD]");

   Function Look_Behind(Parser : in Parslets.Parser) return PE.Expression'Class is
      (raise Program_Error with "UNIMPLEMENTED");
End Parslets;
