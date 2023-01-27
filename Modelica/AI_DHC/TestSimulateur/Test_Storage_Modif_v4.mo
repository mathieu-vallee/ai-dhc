within AI_DHC.TestSimulateur;
model Test_Storage_Modif_v4

///FLUID DEFINITION
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
   parameter String BC_file2 = "modelica://AI_DHC/Data/Storage_setpoint/Storage_setpoint.txt";
   parameter String DC_file = "modelica://AI_DHC/Data/DC/Data_DC.txt";

  /// PARAMETERS FILES FOR PYTHON SCRIPT ///
//   parameter String BC_file = "applied_boundary_conditions.txt";
//   parameter String BC_file2 = "applied_storage_setpoint.txt";
//   parameter String DC_file = "applied_fault_1.txt";

  // INITIAL CONDITIONS
  parameter Modelica.Units.SI.Energy E_sto_ini = 30e6*3600 "Energie initiale dans le stockage";

  // OUTPUTS
  Modelica.Units.SI.Energy E_sto(start=E_sto_ini);

  Modelica.Blocks.Sources.CombiTimeTable BC_TimeTable(
    tableOnFile=true,
    tableName="data_BC",
    fileName=ModelicaServices.ExternalReferences.loadResource(BC_file),
    columns=1:9,
    timeScale(displayUnit="h") = 3600) annotation (Placement(transformation(extent={{-100,80},
            {-80,100}})));
  Modelica.Blocks.Sources.CombiTimeTable DC_TimeTable(
    tableOnFile=true,
    tableName="data_DC",
    fileName=ModelicaServices.ExternalReferences.loadResource(DC_file),
    columns=1:3,
    timeScale(displayUnit="h") = 3600) annotation (Placement(transformation(extent={{-60,80},
            {-40,100}})));
  AI_DHC.Components.Storage.Stratified_modified Storage(
    redeclare package Medium = MediumDHN,
    m_flow_nominal=0.1,
    VTan=600,
    hTan=10,
    dIns=0.5,
    nSeg=10,
    T_start=353.15,
    port_a(m_flow(start=-18.41293131633719)))
                    annotation (Placement(transformation(extent={{-12,-16},{18,14}})));
  IBPSA.Fluid.Sources.MassFlowSource_T Source(
    redeclare package Medium = MediumDHN,
    use_m_flow_in=true,
    use_T_in=true,
    T=283.15,
    nPorts=1) annotation (Placement(transformation(extent={{86,-30},{66,-10}})));
  IBPSA.Fluid.Sources.Boundary_pT sink(
    redeclare package Medium = MediumDHN,
    use_T_in=true,
    T=353.15,
    use_p_in=false,
    nPorts=1) annotation (Placement(transformation(extent={{-84,-10},{-64,10}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort Tout(redeclare package Medium =
        MediumDHN)
    annotation (Placement(transformation(extent={{-26,-10},{-46,10}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort Tin(redeclare package Medium =
        MediumDHN)
    annotation (Placement(transformation(extent={{58,-30},{38,-10}})));
  Modelica.Blocks.Sources.RealExpression kIns_fault(y=DC_TimeTable.y[3])
    annotation (Placement(transformation(extent={{-100,-70},{-72,-46}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCSid1
    "Boundary condition for tank" annotation (Placement(transformation(extent={{-10,70},
            {2,82}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCTop1
    "Boundary condition for tank" annotation (Placement(transformation(extent={{-10,48},
            {2,60}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCBot
    "Boundary condition for tank"
    annotation (Placement(transformation(extent={{-10,30},{2,42}})));
  Modelica.Blocks.Sources.RealExpression T_ext(y=BC_TimeTable.y[3] + 273.15) annotation (Placement(transformation(extent={{-78,42},
            {-50,66}})));
  Modelica.Blocks.Sources.RealExpression Flowrate(y=-BC_TimeTable.y[6]*1000/(
        cp_DHN*(BC_TimeTable.y[7] - BC_TimeTable.y[8])))
    annotation (Placement(transformation(extent={{150,-82},{122,-58}})));
  Modelica.Blocks.Sources.RealExpression T_return(y=BC_TimeTable.y[8] + 273.15) annotation (Placement(transformation(extent={{152,-32},{124,-8}})));
  Modelica.Blocks.Sources.RealExpression T_dep_sp(y=BC_TimeTable.y[7] + 273.15) annotation (Placement(transformation(extent={{-128,24},
            {-100,48}})));
  Modelica.Blocks.Sources.RealExpression m_flow_DHN(y=BC_TimeTable.y[6]*1000/(
        cp_DHN*(BC_TimeTable.y[7] - BC_TimeTable.y[8])))
    annotation (Placement(transformation(extent={{156,-108},{128,-84}})));
  Modelica.Blocks.Sources.CombiTimeTable Storage_setpoint(
    tableOnFile=true,
    tableName="Storage_setpoint",
    fileName=ModelicaServices.ExternalReferences.loadResource(BC_file2),
    columns=3:4,
    timeScale(displayUnit="h") = 3600) annotation (Placement(transformation(extent={{-28,80},{-8,100}})));
  Modelica.Blocks.Sources.RealExpression Discharge(y=if DischargeMode.y then 1e6*Storage_setpoint.y[2] else 0)
    annotation (Placement(transformation(extent={{28,48},{56,72}})));
  Modelica.Blocks.Sources.RealExpression Charge(y=if ChargeMode.y then 1e6*Storage_setpoint.y[1] else 0)
                                                                             annotation (Placement(transformation(extent={{30,22},{58,46}})));
  Modelica.Blocks.Sources.BooleanExpression ChargeMode(y=Storage_setpoint.y[1] > 0.1)
    "1 if charge mode"
    annotation (Placement(transformation(extent={{88,58},{108,78}})));
  Modelica.Blocks.Sources.BooleanExpression DischargeMode(y=Storage_setpoint.y[2] > 0.1)
                                                                           "1 if Discharge" annotation (Placement(transformation(extent={{88,78},{108,98}})));
  Modelica.Blocks.Continuous.LimPID PID(
    controllerType=Modelica.Blocks.Types.SimpleController.P,
    k=1,
    Ti=0.5,
    yMax=70,
    yMin=-70,
    withFeedForward=false)
               annotation (Placement(transformation(extent={{126,40},{146,60}})));
  Modelica.Blocks.Math.Add signal_charge_discharge(k2=-1) annotation (Placement(transformation(extent={{80,26},{100,46}})));
equation

   der(E_sto) = - Storage.Pdecharge - Storage.Ql_flow;

  connect(Tout.port_b, sink.ports[1])
    annotation (Line(points={{-46,0},{-64,0}}, color={0,127,255}));
  connect(Tout.port_a, Storage.port_a) annotation (Line(points={{-26,0},{-12,-1}}, color={0,127,255}));
  connect(Tin.port_a, Source.ports[1])
    annotation (Line(points={{58,-20},{66,-20}}, color={0,127,255}));
  connect(Tin.port_b, Storage.port_b) annotation (Line(points={{38,-20},{22,-20},{22,-1},{18,-1}}, color={0,127,255}));
  connect(kIns_fault.y, Storage.kIns_Ext_Modifier) annotation (Line(points={{-70.6,-58},{-20,-58},{-20,-9.7},{-12.6,-9.7}}, color={0,0,127}));
  connect(TBCTop1.port, Storage.heaPorTop) annotation (Line(points={{2,54},{6,54},{6,10.1}}, color={191,0,0}));
  connect(TBCSid1.port, Storage.heaPorSid) annotation (Line(points={{2,76},{24,76},{24,-1},{11.4,-1}}, color={191,0,0}));
  connect(TBCBot.port, Storage.heaPorBot) annotation (Line(points={{2,36},{26,36},{26,-22},{6,-22},{6,-12.1}}, color={191,0,0}));
  connect(T_ext.y, TBCSid1.T) annotation (Line(points={{-48.6,54},{-16,54},{-16,
          76},{-11.2,76}}, color={0,0,127}));
  connect(T_ext.y, TBCTop1.T)
    annotation (Line(points={{-48.6,54},{-11.2,54}}, color={0,0,127}));
  connect(T_ext.y, TBCBot.T) annotation (Line(points={{-48.6,54},{-16,54},{-16,36},
          {-11.2,36}}, color={0,0,127}));
  connect(T_return.y, Source.T_in) annotation (Line(points={{122.6,-20},{96,-20},{96,-16},{88,-16}},
                              color={0,0,127}));
  connect(T_dep_sp.y, sink.T_in) annotation (Line(points={{-98.6,36},{-92,36},{-92,
          4},{-86,4}}, color={0,0,127}));
  connect(Charge.y, signal_charge_discharge.u2) annotation (Line(points={{59.4,34},{72,34},{72,30},{78,30}}, color={0,0,127}));
  connect(Discharge.y, signal_charge_discharge.u1) annotation (Line(points={{57.4,60},{72,60},{72,42},{78,42}}, color={0,0,127}));
  connect(PID.u_s, signal_charge_discharge.y) annotation (Line(points={{124,50},{116,50},{116,36},{101,36}}, color={0,0,127}));
  connect(Storage.Pdecharge, PID.u_m) annotation (Line(points={{19.8,-14.5},{34,-14.5},{34,18},{136,18},{136,38}}, color={0,0,127}));
  connect(PID.y, Source.m_flow_in) annotation (Line(points={{147,50},{150,50},{150,0},{94,0},{94,-12},{88,-12}}, color={0,0,127}));


  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{160,100}})),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{160,
            100}})),
    experiment(
      StopTime=2419200,
      Interval=600.001,
      __Dymola_Algorithm="Cvode"));
end Test_Storage_Modif_v4;
