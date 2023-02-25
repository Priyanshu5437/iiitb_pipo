# iiitb_pipo -- johnson counter
### Descripton
# Tools Used

### Layout
#### OpenLane and Magic Tool Installation
##### Installation of Python3
```
$ sudo apt install -y build-essential python3 python3-venv python3-pip
```
##### Installation of Docker
```
$ sudo apt-get remove docker docker-engine docker.io containerd runc (removes older version of docker if installed)
$ sudo apt-get update
$ sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release    
$ sudo mkdir -p /etc/apt/keyrings
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null  
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
$ apt-cache madison docker-ce (copy the version string you want to install)
$ sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io docker-compose-plugin (paste the version string copies in place of <VERSION_STRING>)
$ sudo docker run hello-world (If the docker is successfully installed u will get a success message here)
```
##### Installation of OpenLane on ubuntu
```
$ git clone https://github.com/The-OpenROAD-Project/OpenLane.git
$ cd OpenLane/
$ make
$ make test
```
##### Installation of magic on ubuntu
Additional packages to be installed as a part of system requirements to compile magic before magic installation.<br>
###### Installing M4 preprocessor
```
$ sudo apt-get install m4
```
###### Installing tcsh shell
```
$ sudo apt-get install tcsh
```
###### Installing csh shell
```
$ sudo apt-get install csh 
```
###### Installing Xlib.h
```
$ sudo apt-get install libx11-dev
```
###### Installing Tcl/Tk
```
$ sudo apt-get install tcl-dev tk-dev
```
###### Installing Cairo
```
$ sudo apt-get install libcairo2-dev
```
###### Installing OpenGL
```
$ sudo apt-get install mesa-common-dev libglu1-mesa-dev
```
###### Installing ncurses
```
$ sudo apt-get install libncurses-dev
```
###### Installing Magic
```
$ git clone https://github.com/RTimothyEdwards/magic
$ cd magic
$ ./configure
$ make
$ make install
```
##### Installing Klayout
```
$ sudo apt-get install klayout
```

   # PreSynthesis

To clone the repository, download the netlist files and simulate the results, Enter the following commands in your terminal:

```
 $ git clone https://github.com/Priyanshu5437/iiitb_pipo

 $ cd iiitb_pipo
 
 $ iverilog -o iiitb_pipo_out.out iiitb_pipo.v iiitb_pipo_tb.v
 
 $ ./iiitb_pipo_out.out
 
 $ gtkwave iiitb_pipo_vcd.vcd
```

# PostSynthesis

```
$ yosys

yosys> read_liberty -lib ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib

yosys> read_verilog iiitb_pipo.v

yosys> synth -top iiitb_pipo

yosys> dfflibmap -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib

yosys> abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib

yosys> stat

yosys> show

yosys> write_verilog iiitb_pipo_netlist.v

$ iverilog -DFUNCTIONAL -DUNIT_DELAY=#1 ../verilog_model/primitives.v ../verilog_model/sky130_fd_sc_hd.v iiitb_pipo_netlist.v iiitb_pipo_tb.v

$ ./a.out

$ gtkwave iiitb_pipo_vcd.vcd
```
The spice netlist has to be edited to add the libraries we are using, The final spice netlist should look like the following:

```
* SPICE3 file created from sky130_inv.ext - technology: sky130A

.option scale=0.01u
.include ./libs/pshort.lib
.include ./libs/nshort.lib



M1001 Y A VGND VGND nshort_model.0 ad=1435 pd=152 as=1365 ps=148 w=35 l=23
M1000 Y A VPWR VPWR pshort_model.0 ad=1443 pd=152 as=1517 ps=156 w=37 l=23
VDD VPWR 0 3.3V
VSS VGND 0 0V
Va A VGND PULSE(0V 3.3V 0 0.1ns 0.1ns 2ns 4ns)
C0 Y VPWR 0.08fF
C1 A Y 0.02fF
C2 A VPWR 0.08fF
C3 Y VGND 0.18fF
C4 VPWR VGND 0.74fF


.tran 1n 20n
.control
run
.endc
.end
```

Open the terminal in the directory where ngspice is stored and type the following command, ngspice console will open:

```
$ ngspice sky130_inv.spice 
```
# Layout

## Preparation
The layout is generated using OpenLane. To run a custom design on openlane, Navigate to the openlane folder and run the following commands:<br>
```
$ cd designs

$ mkdir iiitb_pipo

$ cd iiitb_pipo

$ mkdir src

$ touch config.json

$ cd src

$ touch iiitb_pipo.v
```

The iiitb_pipo.v file should contain the verilog RTL code you have used and got the post synthesis simulation for. <br>

Copy  `sky130_fd_sc_hd__fast.lib`, `sky130_fd_sc_hd__slow.lib`, `sky130_fd_sc_hd__typical.lib` and `sky130_vsdinv.lef` files to `src` folder in your design. <br>

The final src folder should look like this: <br>
![Screenshot from 2023-02-18 13-26-36](https://user-images.githubusercontent.com/110079807/219848916-2ad1e5ef-9fed-4aaa-b0c3-194949432f6f.png)

The contents of the config.json are as follows. this can be modified specifically for your design as and when required. <br>


```
{ 
   {
  "DESIGN_NAME": "iiitb_pipo",
  "VERILOG_FILES": "dir::src/iiitb_pipo.v",
  "CLOCK_PORT": "clk",
  "CLOCK_NET": "clk",
  "FP_SIZING": "absolute",
  "DIE_AREA": "0 0 60 60",
  "PL_RANDOM_PLACEMENT": 1,
  "LIB_SYNTH" : "dir::src/sky130_fd_sc_hd__typical.lib",
  "LIB_FASTEST" : "dir::src/sky130_fd_sc_hd__fast.lib",
  "LIB_SLOWEST" : "dir::src/sky130_fd_sc_hd__slow.lib",
  "LIB_TYPICAL":"dir::src/sky130_fd_sc_hd__typical.lib",
  "TEST_EXTERNAL_GLOB":"dir::../iiitb_pipo/src/*",
  "SYNTH_DRIVING_CELL":"sky130_vsdinv",
  "pdk::sky130*": {
    "FP_CORE_UTIL": 35,
    "CLOCK_PERIOD": 24,
    "scl::sky130_fd_sc_hd": {
      "FP_CORE_UTIL": 30
    }
  }
}
}
```
# Creating a Custom Inverter Cell

Open Terminal in the folder you want to create the custom inverter cell.

```
$ git clone https://github.com/nickson-jose/vsdstdcelldesign.git

$ cd vsdstdcelldesign

$  cp ./libs/sky130A.tech sky130A.tech

$ magic -T sky130A.tech sky130_inv.mag &
```

![Screenshot from 2023-02-25 11-10-56](https://user-images.githubusercontent.com/110079807/221342730-817473f4-7c66-45e1-990c-5ed9ab4bbcf8.png)
![Screenshot from 2023-02-25 11-50-15](https://user-images.githubusercontent.com/110079807/221342733-cedd74e7-40d6-49bd-8c40-e2a66c126f7c.png)
![Screenshot from 2023-02-25 11-51-14](https://user-images.githubusercontent.com/110079807/221342734-cce1bd52-a482-48c8-b165-88149fcf56bf.png)
1.Rise time:
![Screenshot from 2023-02-25 12-28-37](https://user-images.githubusercontent.com/110079807/221344503-4c12865e-74fd-4cc6-9444-23fcec2c27ea.png)
![Screenshot from 2023-02-25 12-34-34](https://user-images.githubusercontent.com/110079807/221344506-c5828c14-8bfc-479f-87c3-4269e2533edc.png)
`Rise time = (2.2000ns - 2.1567ns) = 43.3ps`
2.Fall time:
![Screenshot from 2023-02-25 12-35-53](https://user-images.githubusercontent.com/110079807/221344508-f6f4ae41-2664-441f-951a-7ceae61c9c9e.png)
![Screenshot from 2023-02-25 12-38-19](https://user-images.githubusercontent.com/110079807/221344512-072881a6-3b0f-405c-ac87-0acaa6b5aa40.png)
`Fall time = (4.06756ns - 4.0401ns) = 27.46ps`
3.Cell rise delay
![Screenshot from 2023-02-25 12-42-54](https://user-images.githubusercontent.com/110079807/221344515-697b2499-7760-4d1c-bbcc-d800a6f185b0.png)
`Cell rise delay = ( 2.18198ns -2.15011ns) =31.7ps`  
4.Cell fall delay
![Screenshot from 2023-02-25 13-00-23](https://user-images.githubusercontent.com/110079807/221344901-99903b5b-ed48-40e7-a48a-405a2ddd74a9.png)
`Cell fall delay = (4.05365 ns- 4.04999ns) = 3.66ps`

Saving changes done and Navigate to the openlane folder in terminal and give  command :<br>
```
$ make mount
```
![Screenshot from 2023-02-24 23-08-33](https://user-images.githubusercontent.com/110079807/221260309-1bdf94c0-bc03-4396-b036-04467976c85d.png)
After entering the openlane container give the following command:<br>
```
$ ./flow.tcl -interactive
```
![Screenshot from 2023-02-24 23-08-48](https://user-images.githubusercontent.com/110079807/221260319-e796eb37-32ce-465d-bc9e-0f5fabce1b2d.png)
In tcl console we need to enter command

```
% package require openlane 0.9
```
![Screenshot from 2023-02-24 23-09-43](https://user-images.githubusercontent.com/110079807/221260392-923fe745-6990-4301-9965-a7439245efab.png)
```
% prep -design iiitb_pipo
```
![Screenshot from 2023-02-24 23-09-55](https://user-images.githubusercontent.com/110079807/221260395-9af8664f-b5d7-457b-870d-bef107a9a7dc.png)
The following commands are to merge external the lef files to the merged.nom.lef. In our case sky130_vsdiat is getting merged to the lef file <br>
```
set lefs [glob $::env(DESIGN_DIR)/src/*.lef]
add_lefs -src $lefs
```
![Screenshot from 2023-02-24 23-10-49](https://user-images.githubusercontent.com/110079807/221260406-6177673d-e469-4839-9220-276d985060da.png)
The contents of the merged.nom.lef file should contain the Macro definition of sky130_vsdinv <br>
<br>

![Screenshot from 2023-02-24 23-16-00](https://user-images.githubusercontent.com/110079807/221260409-00cd162c-4e96-412e-86be-f5f0386c0ffd.png)
## Synthesis
```
% run_synthesis
```
![Screenshot from 2023-02-24 23-16-58](https://user-images.githubusercontent.com/110079807/221260418-24abc269-d259-4321-8d50-d8a8226923ba.png)
### Synthesis Reports
Details of the gates used <br>
<br>
![Screenshot from 2023-02-24 23-19-31](https://user-images.githubusercontent.com/110079807/221260422-83b962c5-244c-44d4-8829-0e6c5b41c84c.png)
Setup and Hold Slack after synthesis<br>
<br>
![Screenshot from 2023-02-24 23-21-11](https://user-images.githubusercontent.com/110079807/221260435-ef113f0c-6dfa-4bcb-80d3-b3f9c642d27b.png)
```
Flop Ratio = Ratio of total number of flip flops / Total number of cells present in the design = 8/71 = 0.1125
```
<br>



## Floorplan
```
% run_floorplan
```
![Screenshot from 2023-02-24 23-22-10](https://user-images.githubusercontent.com/110079807/221260442-5add6180-1ff5-4baf-bb92-27c28ff7ce61.png)
### Floorplan Reports
Die Area and core area <br>
![Screenshot from 2023-02-24 23-24-06](https://user-images.githubusercontent.com/110079807/221260450-85e35c9b-ceea-46da-9d75-558ee47e67cf.png)
Navigate to results->floorplan and type the Magic command in terminal to open the floorplan <br>
```
$ magic -T /home/priyanshu/OpenLane/OpenLane/pdks/sky130A/libs.tech/magic/sky130A.tech read ../../tmp/merged.nom.lef def read iiitb_pipo.def &
```
![Screenshot from 2023-02-24 23-30-39](https://user-images.githubusercontent.com/110079807/221260453-893dc868-e005-47f6-860b-9ed4d904e634.png)
<br>
Floorplan view <br>
![Screenshot from 2023-02-24 23-30-58](https://user-images.githubusercontent.com/110079807/221260458-c112be43-9b18-4930-9b49-3dc1df33ee1b.png)
All the cells are placed in the left corner of the floorplan<br>
<br>
## Placement
```
% run_placement
```
![Screenshot from 2023-02-24 23-32-51](https://user-images.githubusercontent.com/110079807/221260462-821a1c46-d322-4a3c-aa75-371469bd09a1.png)
### Placement Reports
Navigate to results->placement and type the Magic command in terminal to open the placement view <br>
```
$ magic -T /home/priyanshu/OpenLane/OpenLane/pdks/sky130A/libs.tech/magic/sky130A.tech read ../../tmp/merged.nom.lef def read iiitb_pipo.def &
```
![Screenshot from 2023-02-24 23-34-00](https://user-images.githubusercontent.com/110079807/221260468-04174405-e02f-480b-868c-b43aa8391709.png)
![Screenshot from 2023-02-24 23-35-37](https://user-images.githubusercontent.com/110079807/221260479-f9de9210-98a7-4afc-a3ae-5af3559936c1.png)
## Clock Tree Synthesis
```
% run_cts
```
![Screenshot from 2023-02-24 23-37-33](https://user-images.githubusercontent.com/110079807/221260484-7c6c975e-d637-4eaf-849f-e6f7ef86dd70.png)
## Routing
```
% run_routing
```
![Screenshot from 2023-02-24 23-38-14](https://user-images.githubusercontent.com/110079807/221260485-501c6430-1741-4f09-9774-96b569fbcfd1.png)
### Routing Reports
Navigate to results->routing and type the Magic command in terminal to open the routing view <br>
```
$ magic -T /home/priyanshu/OpenLane/OpenLane/pdks/sky130A/libs.tech/magic/sky130A.tech read ../../tmp/merged.nom.lef def read iiitb_pipo.def &
```
![Screenshot from 2023-02-24 23-40-03](https://user-images.githubusercontent.com/110079807/221260492-0a81dfbb-1a31-4ec7-ab5e-8106992faad5.png)
Routing View<br>
<br>
![Screenshot from 2023-02-24 23-40-17](https://user-images.githubusercontent.com/110079807/221260497-82d87884-3104-47f7-898f-a2617f868e44.png)
![Screenshot from 2023-02-24 23-41-14](https://user-images.githubusercontent.com/110079807/221260499-8db60671-a89e-4572-888c-57429b63bfd3.png)
![Screenshot from 2023-02-24 23-44-00](https://user-images.githubusercontent.com/110079807/221260505-638447fd-a821-414b-b2c1-907c52a68c05.png)
### Area Report by MAGIC :<br>
![Screenshot from 2023-02-24 23-44-56](https://user-images.githubusercontent.com/110079807/221260508-b4a45c3b-43f4-47da-a17a-361170563e44.png)
We can also run the whole flow at once instead of step by step process by giving the following command in openlane container<br>
```
$ ./flow.tcl -design iiitb_pipo
```
![Screenshot from 2023-02-24 23-45-51](https://user-images.githubusercontent.com/110079807/221260513-2eb58329-3dbd-41d1-a187-298147e1d371.png)
![Screenshot from 2023-02-24 23-52-01](https://user-images.githubusercontent.com/110079807/221260517-6ae13013-a990-443c-a823-13bda4a1f000.png)
![Screenshot from 2023-02-24 23-52-10](https://user-images.githubusercontent.com/110079807/221260525-98266c14-7987-4cbc-8d88-bc75ddc0c196.png)
![Screenshot from 2023-02-24 23-52-21](https://user-images.githubusercontent.com/110079807/221260529-fb17928d-271d-409c-90f5-9361fd603a54.png)
# Results post-layout

### 1. Post Layout synthesis gate count
![Screenshot from 2023-02-25 00-08-56](https://user-images.githubusercontent.com/110079807/221264114-96f1695b-6da9-4164-ae5b-d6e159daecf9.png)
<b><I> Gate Count =8 </b></I> <br>

### 2. Area (box command)
![Screenshot from 2023-02-24 23-44-56](https://user-images.githubusercontent.com/110079807/221260508-b4a45c3b-43f4-47da-a17a-361170563e44.png)

<b><I> Area =3600  um2</b></I> <br>

### 3. Flop/standard cell ratio
![Screenshot from 2023-02-25 00-08-56](https://user-images.githubusercontent.com/110079807/221264114-96f1695b-6da9-4164-ae5b-d6e159daecf9.png)
<b><I>Flop Ratio = Ratio of total number of flip flops / Total number of cells present in the design = 5/8 = 0.625 </b></I><br>

### 4. Power (internal, switching, leakage and total)
![Screenshot from 2023-02-25 00-11-02](https://user-images.githubusercontent.com/110079807/221264129-9e1999a9-d1da-4e16-8e39-cabd3bdfac6f.png)
<b><I> Internal Power = 30.92 uW (84.2%) </b></I><br>
<b><I> Switching Power =  5.82uW (15.8%) </b></I><br>
<b><I> Leakage Power = 0.209 nW (0.00%) </b></I><br>
<b><I> Total Power = 36.7 uW (100%) </b></I><br>
#### 5.PERFORMANCE
![Screenshot from 2023-02-25 00-22-48](https://user-images.githubusercontent.com/110079807/221267032-75cf55f7-c20a-41b8-bdb6-8468391aaced.png)
![Screenshot from 2023-02-25 00-22-54](https://user-images.githubusercontent.com/110079807/221267057-f609ee0d-df5a-4cc7-8343-decc72f91c6d.png)
<b><I> Performance = 1/(clock period - slack) = 1/(24 - 18.40)ns = 175.571Mhz </b></I><br>
