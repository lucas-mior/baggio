model completo
  Modelica.Blocks.Sources.Constant const(k = 10)  annotation(
    Placement(visible = true, transformation(origin = {-62, -2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  fornalha2 fornalha21 annotation(
    Placement(visible = true, transformation(origin = {28, -2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(const.y, fornalha21.u) annotation(
    Line(points = {{-50, -2}, {24, -2}, {24, 0}}, color = {0, 0, 127}));
  annotation(
    uses(Modelica(version = "4.0.0")));
end completo;