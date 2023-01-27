within AI_DHC.TestSimulateur;
model TestBoiler_Modif_v2

  /// FLUID DEFINITION ///
  constant Modelica.Units.SI.SpecificHeatCapacity cp_DHN=4180;
  constant Modelica.Units.SI.Density d_DHN=990;
  replaceable package MediumDHN =
          Modelica.Media.Water.ConstantPropertyLiquidWater (
           cp_const=cp_DHN,
           cv_const=cp_DHN,
           d_const=d_DHN) constrainedby Modelica.Media.Interfaces.PartialMedium
                                            "DHN Fluid" annotation (Dialog(group="Fluids"));//Water

   /// PARAMETERS FILES ///
    parameter String BC_file = "modelica://AI_DHC/Data/BC/data_BC.txt";
    parameter String DC_file = "modelica://AI_DHC/Data/DC/Data_DC_no_default_G.txt";
    parameter String DC2_file = "modelica://AI_DHC/Data/DC/Data_DC_no_default_eta.txt";

   /// PARAMETERS FILES FOR PYTHON SCRIPT ///
//     parameter String BC_file = "applied_boundary_conditions.txt";
//     parameter String DC_file = "applied_fault_1.txt";
//     parameter String DC2_file = "applied_fault_2.txt";

   parameter Real[:,2] etaT = [293.15, 1.09;
                               303.15, 1.08;
                               313.15, 1.05;
                               323.15, 0.96;
                               373.15, 0.91] "Temperature dependance of efficiency";


  parameter Real dmd_scale = 1.0 "Scale factor for DHC demand";

  Modelica.Blocks.Sources.CombiTimeTable BC_TimeTable(
    tableOnFile=true,
    tableName="data_BC",
    fileName=ModelicaServices.ExternalReferences.loadResource(BC_file),
    columns=1:9,
    timeScale(displayUnit="h") = 3600) annotation (Placement(transformation(extent={{-148,
            -52},{-128,-32}})));

  Modelica.Blocks.Sources.CombiTimeTable DC_TimeTable(
    tableOnFile=true,
    tableName="data_DC",
    fileName=ModelicaServices.ExternalReferences.loadResource(DC_file),
    columns=1:3,
    timeScale(displayUnit="h") = 3600) annotation (Placement(transformation(extent={{-148,
            -80},{-128,-60}})));
  Modelica.Fluid.Sources.MassFlowSource_T boundary(
    redeclare package Medium = MediumDHN,
    use_m_flow_in=true,
    use_T_in=true,
    m_flow=1,
    T=393.15,
    nPorts=1)
    annotation (Placement(transformation(extent={{78,-84},{58,-64}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort Tin(redeclare package Medium = MediumDHN)
    annotation (Placement(transformation(extent={{40,-84},{20,-64}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort Tout(redeclare package Medium = MediumDHN)
    annotation (Placement(transformation(extent={{20,38},{40,58}})));
  Modelica.Fluid.Sources.Boundary_pT boundary1(
    redeclare package Medium = MediumDHN,
    p=1000000,
    nPorts=1)
    annotation (Placement(transformation(extent={{80,38},{60,58}})));
  Modelica.Blocks.Sources.RealExpression Flowrate(y=dmd_scale*BC_TimeTable.y[6]
        *1000/(cp_DHN*(BC_TimeTable.y[7] - BC_TimeTable.y[8])))
    annotation (Placement(transformation(extent={{134,-64},{106,-40}})));
  Modelica.Blocks.Sources.RealExpression T_return(y=BC_TimeTable.y[8] + 273.15) annotation (Placement(transformation(extent={{134,-94},{106,-70}})));
  Components.Boiler.BoilerNoControl_modif boilerNoControl_modif(
    redeclare package Medium = MediumDHN,
    m_flow_nominal=1,
    paramBoiler=Components.Boiler.Boiler_AI_DHC(),
    etaTempBased=etaT)                             annotation (Placement(transformation(extent={{-36,-32},{-2,2}})));
  Modelica.Blocks.Sources.RealExpression T_ext(y=BC_TimeTable.y[3] + 273.15) annotation (Placement(transformation(extent={{134,-36},{106,-12}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature prescribedTemperature annotation (Placement(transformation(extent={{58,-32},{46,-20}})));
  Modelica.Blocks.Sources.RealExpression G_loss_fault(y=DC_TimeTable.y[3]) annotation (Placement(transformation(extent={{-144,42},{-116,66}})));
  Modelica.Blocks.Sources.RealExpression T_dep_sp(y=BC_TimeTable.y[7] + 273.15) annotation (Placement(transformation(extent={{-144,4},{-116,28}})));
  Modelica.Blocks.Sources.RealExpression T_dep_signal(y=boilerNoControl_modif.T_out) annotation (Placement(transformation(extent={{-144,-18},{-116,6}})));
  Modelica.Blocks.Continuous.LimPID PID(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=0.2,
    Ti=3000,
    yMax=1,
    yMin=0,
    Ni=0.9) annotation (Placement(transformation(extent={{-100,0},{-80,20}})));
  Modelica.Blocks.Sources.CombiTimeTable DC2_TimeTable(
    tableOnFile=true,
    tableName="data_DC",
    fileName=ModelicaServices.ExternalReferences.loadResource(DC2_file),
    columns=1:3,
    timeScale(displayUnit="h") = 3600) annotation (Placement(transformation(extent={{-106,
            -98},{-86,-78}})));
  Modelica.Blocks.Sources.RealExpression eta_loss_fault(y=DC2_TimeTable.y[3]) annotation (Placement(transformation(extent={{-144,22},{-116,46}})));
equation
  connect(boundary1.ports[1], Tout.port_b) annotation (Line(points={{60,48},{40,48}}, color={0,127,255}));
  connect(Tin.port_a, boundary.ports[1]) annotation (Line(points={{40,-74},{58,-74}}, color={0,127,255}));
  connect(T_return.y, boundary.T_in) annotation (Line(points={{104.6,-82},{90,-82},{90,-70},{80,-70}},                   color={0,0,127}));
  connect(boundary.m_flow_in, Flowrate.y) annotation (Line(points={{78,-66},{84,-66},{84,-64},{92,-64},{92,-52},{104.6,-52}}, color={0,0,127}));
  connect(Tin.port_b, boilerNoControl_modif.port_a) annotation (Line(points={{20,-74},{-60,-74},{-60,-15},{-36,-15}}, color={0,127,255}));
  connect(boilerNoControl_modif.port_b, Tout.port_a) annotation (Line(points={{-2,-15},{14,-15},{14,30},{-10,30},{-10,48},{20,48}}, color={0,127,255}));
  connect(prescribedTemperature.port, boilerNoControl_modif.T_amb) annotation (Line(points={{46,-26},{20,-26},{20,-23.5},{-7.44,-23.5}}, color={191,0,0}));
  connect(T_ext.y, prescribedTemperature.T) annotation (Line(points={{104.6,-24},{64,-24},{64,-26},{59.2,-26}}, color={0,0,127}));
  connect(G_loss_fault.y, boilerNoControl_modif.G_ext_modifier) annotation (Line(points={{-114.6,54},{-17.3,54},{-17.3,3.70008}},   color={0,0,127}));
  connect(PID.y, boilerNoControl_modif.u_rel) annotation (Line(points={{-79,10},{-48,10},{-48,-3.1},{-30.9,-3.1}}, color={0,0,127}));
  connect(PID.u_s, T_dep_sp.y) annotation (Line(points={{-102,10},{-108,10},{-108,16},{-114.6,16}},                   color={0,0,127}));
  connect(T_dep_signal.y, PID.u_m) annotation (Line(points={{-114.6,-6},{-96,-6},{-96,-8},{-90,-8},{-90,-2}},       color={0,0,127}));
  connect(boilerNoControl_modif.etaT_ext_modifier, eta_loss_fault.y) annotation (Line(points={{-21.04,3.7},{-21.04,34},{-114.6,34}},             color={0,0,127}));
  annotation (Dialog(group="Data"),
              Icon(coordinateSystem(preserveAspectRatio=false, extent={{-160,-100},{140,80}})),
                                                                 Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-160,-100},{140,80}})),
    experiment(
      StopTime=2419200,
      Interval=299.999808,
      Tolerance=1e-07,
      __Dymola_Algorithm="Cvode"));
end TestBoiler_Modif_v2;
