	/* Définitions */

%{

	/* Code C */
int outputLexical = 1;	// flag qui permet d'afficher(1)/masquer(0) les messages de l'analyseur lexicale, par défaut (1)
	/* fonction qui affiche un message passé en paramétre */
void output(const char* msg) {
	if(outputLexical == 1) {
		printf("Analyseur lexicale: %s\n", msg);
	}
}
	/* chaine de caractéres utilisé avec la fonction output() */
char buffer[50];

#include "pascal.tab.h"

%}

%option yylineno

lettre			[a-zA-Z]
chiffre			[0-9]
id 				{lettre}({lettre}|{chiffre})*
nb 				{chiffre}+

blanc			[ \t\n]+
chaine			\'[^\']*\'
commentaire		"{"[^{}]*"}"

%%

	/* Définitions et expressions régulières */

	/*
		lexèmes à reconnaître:
			mots clés:
				begin
				do
				else
				end
				function
				if
				int
				procedure
				program
				then
				var
				while
	*/

[bB][eE][gG][iI][nN]					{ output("mot cle: BEGIN"); 	return BEGIN_TOKEN; 	}
[dD][oO]								{ output("mot cle: DO"); 		return DO; 				}
[eE][lL][sS][eE]						{ output("mot cle: ELSE"); 		return ELSE; 			}
[eE][nN][dD]							{ output("mot cle: END"); 		return END; 			}
[fF][uU][nN][cC][tT][iI][oO][nN]		{ output("mot cle: FUNCTION"); 	return FUNCTION; 		}
[iI][fF]								{ output("mot cle: IF"); 		return IF; 				}
[iI][nN][tT]							{ output("mot cle: INT"); 		return INT; 			}
[pP][rR][oO][cC][eE][dD][uU][rR][eE]	{ output("mot cle: PROCEDURE"); return PROCEDURE; 		}
[pP][rR][oO][gG][rR][aA][mM]			{ output("mot cle: PROGRAM"); 	return PROGRAM; 		}
[tT][hH][eE][nN]						{ output("mot cle: THEN"); 		return THEN; 			}
[vV][aA][rR]							{ output("mot cle: VAR"); 		return VAR; 			}
[wW][hH][iI][lL][eE]					{ output("mot cle: WHILE"); 	return WHILE; 			}

	/*
			nb			(nombres: chiffre chiffre*)
	*/
{nb}									{
											sprintf(buffer, "NB: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											return NB;
										}
[nN][oO][tT]							{
											sprintf(buffer, "OPREL/NOT: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											return NOT;
										}
	/*
			id			(identificateurs)
	*/
{id}									{
											sprintf(buffer, "ID: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											return ID;
										}
	/*
			oprel		(opérateurs relationnels: == <> < > <= >=)
	*/
==|<>|<|>|<=|>=							{
											sprintf(buffer, "OPREL: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											return OPREL;
										}
	/*
			opadd		(+ - or)
	*/
\+|-|[oO][rR]							{
											sprintf(buffer, "OPADD: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											return OPADD;
										}
	/*
			opaffect	(=)
	*/
=										{
											sprintf(buffer, "OPAFFECT: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											return OPAFFECT;
										}
	/*
			opmul		(* / div mod and)
	*/
\*|\/|[dD][iI][vV]|[mM][oO][dD]|[aA][nN][dD]	{
											sprintf(buffer, "OPMUL: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											return OPMUL;
										}
	/*
			* chaine de caractéres
	*/
{chaine} 								{
											sprintf(buffer, "CHAINE: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											return CHAINE;
										}

	/*
			* caractéres blancs: espace, tabulation, retour chariot
	*/
{blanc}									{
											/* les caractéres blancs sont à ignorer, on ne retourne rien */
										}
	/*
			* commentaires: placés entre { ... }
	*/
{commentaire}							{
											sprintf(buffer, "COMMENTAIRE: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											/* les commentaires sont à ignorer aussi */
										}
	/*
		Les caractéres restants
	*/
.										{
											sprintf(buffer, "AUTRE: %s (%d caractere(s))", yytext, yyleng);
											output(buffer);
											/* dans le cas des autres caractéres, on doit le retourner tel qu'il est */
											return *yytext;	/* ou alors, return yytext[0] */
										}

%%

	/* Code C */

int yywrap(void) {
	return 1;
}
