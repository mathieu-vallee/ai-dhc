within AI_DHC.TestSimulateur;
model TestHeatPump

  /// FLUID DEFINITION ///
  constant Modelica.Units.SI.SpecificHeatCapacity cp_DHN=4180;
  constant Modelica.Units.SI.Density d_DHN=990;
  replaceable package MediumDHN = Modelica.Media.Water.ConstantPropertyLiquidWater (
      cp_const=cp_DHN,
      cv_const=cp_DHN,
      d_const=d_DHN) constrainedby Modelica.Media.Interfaces.PartialMedium "DHN Fluid" annotation (Dialog(group="Fluids"));

  parameter String BC_file="modelica://AI_DHC/Data/BC/data_BC.txt";
  parameter String DC_file="modelica://AI_DHC/Data/DC/Data_DC_rampe_exemple.txt";

  /// PARAMETERS FILES FOR PYTHON SCRIPT ///
  //parameter String BC_file = "applied_boundary_conditions.txt";
  //parameter String DC_file = "applied_fault_1.txt";
  //Water
  Modelica.Blocks.Sources.RealExpression NoIcing(y=1) annotation (Placement(transformation(extent={{-54,-84},{-34,-64}})));
  Modelica.Fluid.Sources.Boundary_pT boundary1(redeclare package Medium = MediumDHN, nPorts=1) annotation (Placement(transformation(extent={{180,0},{160,20}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort TConOut(redeclare package Medium = MediumDHN) annotation (Placement(transformation(extent={{94,-2},{114,18}})));
  Modelica.Fluid.Sources.MassFlowSource_T boundary(
    redeclare package Medium = MediumDHN,
    use_m_flow_in=true,
    use_T_in=true,
    m_flow=1,
    T(displayUnit="degC") = 323.15,
    nPorts=1) annotation (Placement(transformation(extent={{-108,38},{-88,58}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort TconIn(redeclare package Medium = MediumDHN) annotation (Placement(transformation(extent={{-74,34},{-54,54}})));
  AixLib.Fluid.Sources.MassFlowSource_T sourceSideMassFlowSource(
    use_m_flow_in=true,
    m_flow=100,
    use_T_in=true,
    redeclare package Medium = MediumDHN,
    T=293.15,
    nPorts=1) "Ideal mass flow source at the inlet of the source side" annotation (Placement(transformation(extent={{116,-46},{96,-26}})));
  AixLib.Fluid.Sources.Boundary_pT sinkSideFixedBoundary(redeclare package Medium = MediumDHN, nPorts=1) "Fixed boundary at the outlet of the sink side"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-146,-86})));
  Modelica.Blocks.Sources.BooleanExpression booleanExpression1(y=true) annotation (Placement(transformation(extent={{-132,-66},{-112,-46}})));

  Components.HeatPump.HeatPump heatPump(
    redeclare package Medium_con = MediumDHN,
    redeclare package Medium_eva = MediumDHN,
    use_rev=false,
    use_autoCalc=false,
    Q_useNominal(displayUnit="kW") = 100000,
    scalingFactor=1,
    use_refIne=false,
    mFlow_conNominal=18,
    VCon=0.5,
    dpCon_nominal=0,
    use_conCap=false,
    mFlow_evaNominal=70,
    VEva=0.5,
    dpEva_nominal=0,
    use_evaCap=false,
    transferHeat=false,
    initType=Modelica.Blocks.Types.Init.InitialState,
    TCon_start=TCon_start,
    TEva_start=TEva_start,
    redeclare model PerDataMainHP = Database.HeatPump.PerformanceData.PolynomalApproach (redeclare function PolyData =
            AI_DHC.Database.HeatPump.Functions.Characteristics.CarnotFunction (
            Pel_nominal(displayUnit="kW") = 6000000,
            etaCarnot_nominal=0.8,
            a={0,2,-1})),
    senT_b2(T(start=273.15 + 10))) annotation (Placement(transformation(extent={{-20,-54},{46,24}})));
  Modelica.Blocks.Sources.CombiTimeTable BC_TimeTable(
    tableOnFile=true,
    tableName="data_BC",
    fileName=ModelicaServices.ExternalReferences.loadResource(BC_file),
    columns=1:9,
    timeScale(displayUnit="h") = 3600) annotation (Placement(transformation(extent={{-202,78},{-182,98}})));
  Modelica.Blocks.Sources.CombiTimeTable DC_TimeTable(
    tableOnFile=true,
    tableName="data_DC",
    fileName=ModelicaServices.ExternalReferences.loadResource(DC_file),
    columns=1:3,
    timeScale(displayUnit="h") = 3600) annotation (Placement(transformation(extent={{-200,0},{-180,20}})));
  Modelica.Blocks.Continuous.LimPID PID(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    yMax=1,
    yMin=0,
    Ni=0.9) annotation (Placement(transformation(extent={{64,68},{84,88}})));
  Modelica.Blocks.Sources.RealExpression T_dep_sp(y=BC_TimeTable.y[7] + 273.15) annotation (Placement(transformation(extent={{-44,70},{-16,94}})));
  Modelica.Blocks.Sources.RealExpression Flowrate1(y=BC_TimeTable.y[6]*1000/(cp_DHN*(BC_TimeTable.y[7] - BC_TimeTable.y[8])))
    annotation (Placement(transformation(extent={{-154,66},{-126,90}})));
  Modelica.Blocks.Sources.RealExpression T_return(y=BC_TimeTable.y[8] + 273.15) annotation (Placement(transformation(extent={{-160,16},{-132,40}})));

  AixLib.BoundaryConditions.GroundTemperature.GroundTemperatureKusuda groundTemperatureKusuda(
    t_shift=23,
    alpha=0.039,
    D=0.1,
    T_amp=1,
    T_mean=286.95) "Undisturbed ground temperature model" annotation (Placement(transformation(extent={{206,-52},{186,-32}})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor GroundTemp "Sensor to show ground temperature"
    annotation (Placement(transformation(extent={{164,-56},{144,-36}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort TEvaOut(redeclare package Medium = MediumDHN) annotation (Placement(transformation(extent={{-70,-92},{-90,-112}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort TevaIn(redeclare package Medium = MediumDHN) annotation (Placement(transformation(extent={{80,-24},{60,-44}})));
  Modelica.Blocks.Math.Add add(k2=-1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={42,-124})));
  Modelica.Blocks.Sources.RealExpression DTEvap(y=2) annotation (Placement(transformation(extent={{82,-144},{102,-124}})));
  Modelica.Blocks.Sources.RealExpression T_dep_sp1(y=80 + 273.15) annotation (Placement(transformation(extent={{8,40},{36,64}})));
  Modelica.Blocks.Sources.RealExpression massflow_source_theorique(y=Demande*(COP + 1)/(1e-10 + COP)/(cp_DHN*20))
    annotation (Placement(transformation(extent={{158,-30},{138,-10}})));
  Modelica.Blocks.Sources.RealExpression massflow_source1(y=if time < 3600*5 then massflow_source_theorique.y else limIntegrator.y)
    annotation (Placement(transformation(extent={{78,-80},{98,-60}})));
  Modelica.Blocks.Continuous.LimIntegrator limIntegrator(
    k=0.3,
    outMax=1000,
    outMin=0)    annotation (Placement(transformation(extent={{154,-100},{174,-80}})));
  Modelica.Blocks.Math.Add add1(k2=-1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={124,-110})));
  parameter Modelica.Media.Interfaces.Types.Temperature TCon_start=80 + 273.15 "Start value of temperature";
  parameter Modelica.Media.Interfaces.Types.Temperature TEva_start=273.15 + 2 "Start value of temperature";
  Modelica.Units.SI.Power Demande=BC_TimeTable.y[6]*1000;
  Real COP=heatPump.innerCycle.QCon/(1e-10 + heatPump.innerCycle.Pel);

  Modelica.Units.SI.Power P_elec = heatPump.innerCycle.Pel;
  Modelica.Units.SI.Power P_eva = heatPump.innerCycle.QEva;
  Modelica.Units.SI.Power P_cond = heatPump.innerCycle.QCon;

  Modelica.Units.SI.Temperature T_cond_out = vapourCompressionMachineControlBus.TConOutMea;
  Modelica.Units.SI.Temperature T_cond_in = vapourCompressionMachineControlBus.TConInMea;
  Modelica.Units.SI.Temperature T_eva_out = vapourCompressionMachineControlBus.TEvaOutMea;
  Modelica.Units.SI.Temperature T_eva_in = vapourCompressionMachineControlBus.TEvaInMea;

  Modelica.Units.SI.Energy Energy_elec;
  Modelica.Units.SI.Energy Energy_eva;
  Modelica.Units.SI.Energy Energy_cond;

  Components.HeatPump.BaseClasses.VapourCompressionMachineControlBus vapourCompressionMachineControlBus
    annotation (Placement(transformation(extent={{-98,-46},{-58,-6}})));
  Modelica.Blocks.Sources.RealExpression No_fault(y=0) annotation (Placement(transformation(extent={{-194,-74},{-166,-50}})));
  Modelica.Blocks.Logical.Switch switch1 annotation (Placement(transformation(extent={{-136,-10},{-116,10}})));
  Modelica.Blocks.Sources.BooleanExpression booleanExpression2(y=true) annotation (Placement(transformation(extent={{-188,-24},{-168,-4}})));
equation

  der(Energy_elec) = P_elec;
  der(Energy_eva) = P_eva;
  der(Energy_cond) = P_cond;

  connect(boundary1.ports[1], TConOut.port_b) annotation (Line(points={{160,10},{114,10},{114,8}}, color={0,127,255}));
  connect(TconIn.port_b, heatPump.port_a1) annotation (Line(points={{-54,44},{-34,44},{-34,4.5},{-20,4.5}}, color={0,127,255}));
  connect(heatPump.port_b1, TConOut.port_a) annotation (Line(points={{46,4.5},{94,8}}, color={0,127,255}));
  connect(NoIcing.y, heatPump.iceFac_in) annotation (Line(points={{-33,-74},{-12.08,-74},{-12.08,-59.2}}, color={0,0,127}));
  connect(PID.u_m, TConOut.T) annotation (Line(points={{74,66},{74,22},{104,22},{104,19}}, color={0,0,127}));
  connect(PID.y, heatPump.nSet) annotation (Line(points={{85,78},{92,78},{92,56},{52,56},{52,30},{-36,30},{-36,-8.5},{-25.28,-8.5}}, color={0,0,127}));
  connect(boundary.ports[1], TconIn.port_a) annotation (Line(points={{-88,48},{-80,48},{-80,44},{-74,44}}, color={0,127,255}));
  connect(groundTemperatureKusuda.port, GroundTemp.port) annotation (Line(points={{186.6,-47},{164,-46}}, color={191,0,0}));
  connect(TEvaOut.port_a, heatPump.port_b2) annotation (Line(points={{-70,-102},{-62,-102},{-62,-34.5},{-20,-34.5}}, color={0,127,255}));
  connect(TEvaOut.port_b, sinkSideFixedBoundary.ports[1]) annotation (Line(points={{-90,-102},{-126,-102},{-126,-86},{-136,-86}}, color={0,127,255}));
  connect(TevaIn.port_b, heatPump.port_a2) annotation (Line(points={{60,-34},{50,-34},{50,-34.5},{46,-34.5}}, color={0,127,255}));
  connect(TevaIn.port_a, sourceSideMassFlowSource.ports[1]) annotation (Line(points={{80,-34},{88,-34},{88,-36},{96,-36}}, color={0,127,255}));
  connect(TevaIn.T, add.u1) annotation (Line(points={{70,-45},{70,-106},{22,-106},{22,-118},{30,-118}}, color={0,0,127}));
  connect(T_dep_sp.y, PID.u_s) annotation (Line(points={{-14.6,82},{54,82},{54,78},{62,78}}, color={0,0,127}));
  connect(Flowrate1.y, boundary.m_flow_in) annotation (Line(points={{-124.6,78},{-108,78},{-108,56}}, color={0,0,127}));
  connect(T_return.y, boundary.T_in) annotation (Line(points={{-130.6,28},{-120,28},{-120,52},{-110,52}}, color={0,0,127}));
  connect(GroundTemp.T, sourceSideMassFlowSource.T_in) annotation (Line(points={{143,-46},{128,-46},{128,-32},{118,-32}}, color={0,0,127}));
  connect(TEvaOut.T, add.u2) annotation (Line(points={{-80,-113},{-80,-130},{30,-130}}, color={0,0,127}));
  connect(add.y, add1.u1) annotation (Line(points={{53,-124},{78,-124},{78,-104},{112,-104}}, color={0,0,127}));
  connect(DTEvap.y, add1.u2) annotation (Line(points={{103,-134},{106,-134},{106,-122},{104,-122},{104,-116},{112,-116}}, color={0,0,127}));
  connect(limIntegrator.u, add1.y) annotation (Line(points={{152,-90},{144,-90},{144,-110},{135,-110}}, color={0,0,127}));
  connect(massflow_source1.y, sourceSideMassFlowSource.m_flow_in) annotation (Line(points={{99,-70},{132,-70},{132,-28},{118,-28}}, color={0,0,127}));
  connect(booleanExpression1.y, vapourCompressionMachineControlBus.modeSet) annotation (Line(points={{-111,-56},{-77.9,-56},{-77.9,-25.9}},              color={255,0,
          255}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(heatPump.sigBus, vapourCompressionMachineControlBus) annotation (Line(
      points={{-19.67,-27.675},{-19.67,-26},{-78,-26}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(No_fault.y, switch1.u3) annotation (Line(points={{-164.6,-62},{-138,-62},{-138,-8}},             color={0,0,127}));
  connect(switch1.y, vapourCompressionMachineControlBus.COP_modifier) annotation (Line(points={{-115,0},{-77.9,0},{-77.9,-25.9}},                 color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(booleanExpression2.y, switch1.u2) annotation (Line(points={{-167,-14},{-146,-14},{-146,0},{-138,0}},     color={255,0,255}));
  connect(DC_TimeTable.y[3], switch1.u1) annotation (Line(points={{-179,10},{-146,10},{-146,8},{-138,8}},   color={0,0,127}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-140},{220,100}})),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-200,-140},{220,100}})),
    experiment(
      StopTime=2419200,
      Interval=600.0012,
      Tolerance=1e-05,
      __Dymola_Algorithm="Cvode"));
end TestHeatPump;
