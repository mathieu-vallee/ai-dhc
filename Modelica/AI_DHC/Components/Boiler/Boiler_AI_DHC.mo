within AI_DHC.Components.Boiler;
record Boiler_AI_DHC "Virtual Gas-fired boiler for the project AI-DHC"
  extends AixLib.DataBase.Boiler.General.BoilerTwoPointBaseDataDefinition(
    name="Base_AIDHC",
    volume=Q_nom * 2.0*1e-6,
    pressureDrop=3240000000.0,
    Q_nom=6000000,
    Q_min=2000000,
    eta=[  0.3,0.91;
           0.6,0.935;
           0.8,0.955;
           0.9,0.96;
           1.0,0.95]);

    annotation (Documentation(revisions="<html><ul>
  <li>
    <i>December 08, 2016&#160;</i> by Moritz Lauster:<br/>
    Adapted to AixLib conventions
  </li>
  <li>
    <i>June 23, 2006&#160;</i> by Ana Constantin:<br/>
    implemented
  </li>
</ul>
</html>", info="<html>
<p>
  Source:
</p>
<ul>
  <li>Product: Vitogas 200-F
  </li>
  <li>Manufacturer: Viessmann
  </li>
  <li>Broschure: Vitogas 200-F; 5/2010
  </li>
</ul>
</html>"));
end Boiler_AI_DHC;
