model simples
  Modelica.Blocks.Interfaces.RealInput u annotation(
    Placement(visible = true, transformation(origin = {-102, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0), iconTransformation(origin = {-84, 46}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    Real x;
equation
   x = u;
annotation(
    uses(Modelica(version = "4.0.0")));
end simples;