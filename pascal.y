%{

	#include <stdio.h>
	#include <stdlib.h>
	int yylex(void);
	void yyerror(char*);

	int outputSyntaxique = 1;	// flag qui permet d'afficher(1)/masquer(0) les messages de l'analyseur syntaxique, par défaut (1)
		/* fonction qui affiche un message passé en paramétre */
	void output_syn(const char* msg) {
		if(outputSyntaxique == 1) {
			printf("Analyseur syntaxique: %s\n", msg);
		}
	}

%}

%debug

	/* l'axiome de la grammaire */
%start programme

%token ID
%token NB
%token OPADD
%token OPAFFECT
%token OPMUL
%token OPREL

	/* Mots clés */
%token BEGIN_TOKEN
%token DO
%token ELSE
%token END
%token FUNCTION
%token IF
%token NOT
%token PROCEDURE
%token PROGRAM
%token THEN
%token VAR
%token WHILE
%token INT

%token CHAINE

%error-verbose

%%

programme:
	PROGRAM 					
	ID 							
	';'							
	declaration 				
	instruction_composee		
	'.'						{ output_syn("fin du programme"); }
|	PROGRAM ID error 		{ yyerror("point virgule omis"); }
;

declaration:
	declaration_var				
	declarations_sous_programmes
;

declaration_var:
	declaration_var		
	VAR 				
	liste_identificateurs
	':'					
	INT 				
	';'					
|	/* chaîne vide */
|	declaration_var		
	VAR 				
	liste_identificateurs
	':'					
	error 					{ yyerror("mot cle 'int' introuvable !"); }
;

liste_identificateurs:
	ID 							
|	liste_identificateurs		
	','							
	ID
;

declarations_sous_programmes:
	declarations_sous_programmes
	declarations_sous_programme 
	';'							
|	/* chaîne vide */
;

declarations_sous_programme:
	entete_sous_programme		
	declaration 				
	instruction_composee
;

entete_sous_programme:
	FUNCTION					
	ID 							
	arguments					
	':'							
	INT 						
	';'							
|	PROCEDURE 					
	ID 							
	arguments 					
	';'
;

arguments:
	'(' 						
	liste_parametres 			
	')' 						
|	/* chaîne vide */
;

liste_parametres:
	parametre 					
|	liste_parametres 			
	';' 						
	parametre
;

parametre:
	ID 							
	':' 						
	INT 						
|	VAR 						
	ID 							
	':' 						
	INT
;

instruction_composee:
	BEGIN_TOKEN
	instructions_optionnelles
	END
;

instructions_optionnelles:
	liste_instructions
;

liste_instructions:
	instruction ';'
|	liste_instructions
	instruction ';'
|	instruction
	error 					{ yyerror("point virgule d'instruction omis"); }
;

instruction:
	variable
	OPAFFECT
	expression
|	appel_de_procedure
|	instruction_composee
|	IF
	expression
	THEN
	instruction
	ELSE
	instruction
|	WHILE
	expression
	DO
	instruction
|	/* chaîne vide */
;

variable:
	ID
;

appel_de_procedure:
	ID
|	ID
	'('
	liste_expressions
	')'
;


liste_expressions:
	expression
|	liste_expressions
	','
	expression
;

expression:
	expression_simple
|	expression_simple
	OPREL
	expression_simple
;

expression_simple:
	terme
|	signe terme
|	expression_simple
	OPADD
	terme
;

terme:
	facteur
|	terme
	OPMUL
	facteur
;

facteur:
	ID
|	ID
	'('
	liste_expressions
	')'
|	NB
|	'('
	expression
	')'
|	NOT
	facteur
|	CHAINE
;

signe:
	'+'
|	'-'
;

%%

#include "lex.yy.c"

void yyerror(char *s) {
	extern int yylineno;
	char str[100];
	sprintf(str,"Erreur (ligne n %d): %s\n", yylineno, s);
	printf(str);
}

int main(int argc, char *argv[]) {
	yydebug = 0;
	argc--, argv++;	/* ignorer le 1er paramétre: le nom du fichier C actuel */
	if(argc > 0) {
		yyin = fopen(argv[0], "r");
	} else {
		printf("fichier introuvable !");
		return 0;
	}
	yyparse();
	return 0;
}
