program HelloWorld;

var
    i,x : int;

function factorielle(n: int): int;
begin
  if n <= 1 then
    factorielle = 1
  else
    factorielle = n*factorielle(n - 1);
end;

begin
	i = 2;
	x = 314;
	writeln('Hello World');
	readln;
end.
