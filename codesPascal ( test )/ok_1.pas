program HelloWorld;

function factorielle(n: int): int;
begin
  if n <= 1 then
    factorielle = 1
  else
    factorielle = n*factorielle(n - 1);
end;

begin
writeln('Hello World');
readln;
end.


