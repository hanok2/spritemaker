unit CloudsGeneratorNodeUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, GeneratorNodeUnit, RichView, RVStyle, SimSpin, SSXMLUnit;

type

TCloudsGeneratorNodeUnit=class(TGeneratorNodeUnit)

  Width,Height,Iterations,CloudCover,CloudSharpness,RootSeed,Filter,Intensity,Distortion:Integer;

  constructor Create;override;
  destructor Destroy;override;

  procedure Generate;override;
  procedure RenderTexture(_sizex,_sizey:Integer);override;

end;

implementation

  Uses GeneratorTreeUnit, SSTextureGeneratorUnit, ConstantsUnit;

constructor TCloudsGeneratorNodeUnit.Create;
begin
  inherited;
  Width:=16;
  Height:=16;
  filter:=1;
  iterations:=5;
  Distortion:=0;
  Intensity:=50;
  CloudCover:=500;
  CloudSharpness:=1;
  RootSeed:=1;
  AddParam_List('Filter','PERLIN LINERAR=0,PERLIN COSINUS=1,REGULAR=2,REGULAR LOW=3,CRATES LINEAR=4,CRATES SIN=5,FLASH LINEAR=6,FLASH COSINUS=7',@Filter);
  AddParam_Int('Width',1,1000,@Width);
  AddParam_Int('Height',1,1000,@Height);
  AddParam_Int('Iterations',0,12,@Iterations);
  AddParam_Int('Intensity',0,100,@Intensity);
  AddParam_Int('Distortion',0,10000,@Distortion);
  AddParam_Int('CloudCover',0,1000,@CloudCover);
  AddParam_Int('CloudSharpness',0,1000,@CloudSharpness);
  AddParam_Int('RootSeed',1,1000,@RootSeed);
end;

destructor TCloudsGeneratorNodeUnit.Destroy;
begin
  inherited;

end;

procedure TCloudsGeneratorNodeUnit.Generate;
  var
    Node:TGeneratorNode;
begin
  Node:=TGeneratorNode(GeneratorNodePtr);
  Node.TextureGenerator.Generate_Clouds(width,height,filter,iterations,Intensity/100,Distortion/10000,CloudCover/1000,1.0*CloudSharpness/1000,rootseed);
  Node.TextureGenerator.Transparency_FillAlpha(1);
end;

procedure TCloudsGeneratorNodeUnit.RenderTexture(_sizex,_sizey:Integer);
  var
    Node:TGeneratorNode;
begin
  Node:=TGeneratorNode(GeneratorNodePtr);
  if Node.TextureRenderer<>nil then Node.TextureRenderer.Destroy;
  Node.TextureRenderer:=TTextureGenerator.Create;
  Node.TextureRenderer.Width := _sizex;
  Node.TextureRenderer.Height := _sizey;
  Node.TextureRenderer.Generate_Clouds(width,height,filter,iterations,Intensity/100,Distortion/10000,CloudCover/1000,1.0*CloudSharpness/1000,rootseed);
  Node.TextureRenderer.Transparency_FillAlpha(1);
end;

end.

