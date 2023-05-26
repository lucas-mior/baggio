model SpringMassSystem
  parameter Real k = 1.0 "Spring constant (N/m)";
  parameter Real m = 0.5 "Mass (kg)";
  
  Real x(start=1.0) "Displacement (m)";
  Real v(start=1.0) "Velocity (m/s)";
  Real F "Force (N)";
  
equation
  F = -k * x; // Hooke's Law
  der(v) = F / m; // Newton's Second Law
  der(x) = v; // Definition of velocity

end SpringMassSystem;