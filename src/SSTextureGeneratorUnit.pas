{*******************************************************************************

  Проект: SpaceSim
  Автор: Фомин С.С.
  Дата: 2009 год

  Назначение модуля:

  http://www.x256.ru/article/25?SID=4d0f3dc44cd784193e0d0d8798841fd0

  http://www.xnadev.ru/print.php?type=A&item_id=29

*******************************************************************************}
unit SSTextureGeneratorUnit;

{$mode objfpc}{$H+}

interface

{******************************************************************************}
uses
  Classes, SysUtils, VectorTypes, Windows, Dialogs, Graphics, Math,
  SSNoiseUnit, SSVector, SSColor, SSConstantsUnit, rgb_graphics, RGBGraphics;

{******************************************************************************}
const
  onedivffff = 1 / $FFFF;

  TG_Empty = 0;
  TG_Primitive_ZCircle = 1;
  TG_Primitive_ZSquare = 2;
  TG_Primitive_ZSinSquare = 3;
  TG_Primitive_ZStar = 4;
  TG_Primitive_ZTechAlpha = 5;
  TG_Primitive_ZCell = 6;

  TG_Generate_SolidColor = 7;
  TG_Generate_Noise      = 8;
  TG_Generate_Turbulence = 32;
  TG_Generate_PerlinNoise = 9;
  TG_Generate_Gradient   = 10;
  TG_Generate_Bricks     = 11;
  TG_Generate_Plasma     = 12;
  TG_Generate_WoodRings  = 13;
  TG_Generate_Cells      = 14;
  TG_Generate_Clouds     = 15;

  TG_Color_ChangeHSB     = 16;
  TG_Color_ColorGradient = 17;
  TG_Color_Colorize      = 31;

  TG_Filter_GaussianBlur = 18;

  TG_Combine_Blend     = 20;
  TG_Combine_AlphaMask = 21;

  TG_Transparency_MakeAlpha      = 19;
  TG_Transparency_FillAlpha      = 25;
  TG_Transparency_AlphaFromColor = 26;

  TG_Transform_Rotate  = 22;
  TG_Transform_Move    = 23;
  TG_Transform_Fractalize = 24;
  TG_Transform_Waves   = 27;
  TG_Transform_Twist   = 29;
  TG_Transform_Distort = 30;

  TG_Lighting_Lighting = 33;
  TG_Lighting_ReliefLighting = 34;
  TG_Lighting_NormalMap = 35;

  TG_Project_EnvironmentMapping = 28;

{******************************************************************************}
type
  {******************************************************************************}
  TTextureGenerator = class

    imagetype: integer;

    IsLoaded: boolean; // rgba^[]- создан
    IsCached: boolean; // TRGB32.rbm - создан
    IsCachedGL: boolean; // OpenGL texID - создана текстура OpenGL

    Transparent:   boolean;
    Width, Height: integer;
    WidthMul, HeightMul: integer;

    rbm: TRGB32BitMap;

    rgba: PRGBAColorArray;

    texID:integer;//GLuint;

    IsAlpha:    boolean;
    format:     integer;
    colourType: integer;
    wrapType:   integer;
    filterType: integer;
    mipmap:     integer;

    constructor Create;
    destructor Destroy;

    procedure OnInitContext;
    procedure OnDestroyContext;

    procedure SetFrom(tg: TTextureGenerator);

    procedure SetSize(_Width, _Height: integer);
    procedure SetNewBitmap;
    procedure SetTexture;

    function GetPixel(fx, fy: single): TRGBAColor; // 0<=fx,fy<=1 -

    // Установка в rgba 32-х битный битмап rgm
    procedure Cache(_IsAlpha: boolean);
    procedure UnCache;

    // Текстуры в OpenGL
    procedure CacheGL;
    procedure UnCacheGL;

    procedure Primitive_Rect(x1, y1, x2, y2: integer; r, g, b, a: single);
    procedure Primitive_RadRect(px, py, Iterations: integer; r, g, b, a: single);

    // Примитивы для генераторов шума
    procedure Primitive_ZCircle(px, py, sx, sy: integer; irrx, irry: single);
    procedure Primitive_ZSquare(px, py, sx, sy: integer; irrx, irry: single);
    procedure Primitive_ZSinSquare(px, py, sx, sy: integer; irrx, irry: single);
    procedure Primitive_ZStar(px, py, sx, sy: integer; irrx, irry: single);
    procedure Primitive_ZTechAlpha(px, py, sx, sy: integer; irrx, irry: single);
    procedure Primitive_ZCell(px, py, sx, sy: integer; irrx, irry: single);

    // Генерация
    procedure Generate_SolidColor(r, g, b, a: single);
    procedure Generate_Noise(w, h: integer; filter, iterations: integer;intensity, distortion: single; rootseed: cardinal);
    procedure Generate_Turbulence(rootseed: cardinal; w, h, Iterations: integer);
    procedure Generate_PerlinNoise(rootseed: cardinal);
    procedure Generate_Gradient(w, h, gradient: integer; rootseed: cardinal);
    procedure Generate_Bricks(w, h: integer;border, shifts, widthvariation, slidevariation: single; rootseed: cardinal);
    procedure Generate_Plasma(w, h: integer; rootseed: cardinal);
    procedure Generate_WoodRings(w, h, ax, ay: integer;density: single;iterations: integer; rootseed: cardinal);
    procedure Generate_Cells(w, h, squaretype: integer;irregularity, distribution, scale: single; rootseed: cardinal);
    procedure Generate_Clouds(w, h: integer; filter, iterations: integer;intensity, distortion, CloudCover, CloudSharpness: single; rootseed: cardinal);

    // Цвета
    procedure Color_ChangeBCI(b, c, i: single);
    procedure Color_ChangeHSB(h, s, b: integer);
    procedure Color_ColorGradient(gradient: TRGBAGradient);
    procedure Color_Colorize(color: TRGBAColor; mode, method: integer);
    procedure Color_ToneCurve;

    // Прозрачность
    procedure Transparency_FillAlpha(_alpha: single);
    procedure Transparency_AlphaFromColor(method: integer; kc, kr, kg, kb: single);
    procedure Transparency_MakeAlpha(alphasource: TTextureGenerator; inverse: integer);

    // Фильтры
    procedure Filter_GaussianBlur(Iterations: single);

    // Преобразования
    procedure Transform_Fractalize(src: TTextureGenerator; iterations, blend: integer);
    procedure Transform_Rotate(src: TTextureGenerator; angle: single);
    procedure Transform_Move(src: TTextureGenerator; dx, dy: single);
    procedure Transform_Distort(src, dir, dist: TTextureGenerator;intensitydir, intensitydist: single; mode: integer);
    procedure Transform_Waves(src: TTextureGenerator;method: integer;ax, bx, ay, by: single);
    procedure Transform_Twist(src: TTextureGenerator;amount, size, zoomin, zoomout, xpos, ypos: single);
    procedure Transform_Disorder(one, two, alpha: TTextureGenerator; method: integer);

    // Комбинации текстур в одну
    procedure Combine_AlphaMask(one, two, alpha: TTextureGenerator; inversed: integer);
    procedure Combine_Blend(one, two: TTextureGenerator; method, mode: integer);

    // Освещение
    procedure Lighting_Lighting(src: TTextureGenerator;lx,ly,lz:Single;Relief:Single;NormalMapSmooth,Invert:Integer);
    procedure Lighting_ReliefLighting(src,rel: TTextureGenerator; lx,ly,lz:Single;Relief:Single;NormalMapSmooth,Invert:Integer);
    procedure Lighting_NormalMap(src: TTextureGenerator;Relief:Single;NormalMapSmooth,Invert:Integer);

    // Проецирование текстуры
    procedure Project_EnvironmentMapping(src: TTextureGenerator; plane, mode: integer);
  end;


  {******************************************************************************}
  PTextureGeneratorArray = ^TTextureGeneratorArray;
  TTextureGeneratorArray = array [0..10000000] of TTextureGenerator;

  TTextureGeneratorList = class

  private
    TextureGeneratorArray: PTextureGeneratorArray;

  public
    Count: integer;

    constructor Create;
    destructor Destroy;

    procedure OnInitContext;
    procedure OnDestroyContext;

    function Get(index: integer): TTextureGenerator;
    procedure Put(index: integer; const Value: TTextureGenerator);

    procedure Clear;
    procedure SetLength(NewLength: integer);

    function Add: TTextureGenerator;
    function Insert(index: integer): TTextureGenerator;
    function Push: TTextureGenerator;
    procedure Pop;
    procedure Delete(index: integer);

    property item[index: integer]: TTextureGenerator Read Get; default;

  end;

{******************************************************************************}

{******************************************************************************}
implementation

{******************************************************************************}
procedure TTextureGenerator.SetSize(_Width, _Height: integer);
begin
  Width  := _Width;
  Height := _Height;
end;

 {******************************************************************************}
 //  function cosint(t:Single):Single;inline;
 //  begin
//   // result:=sin(t*3.1415927*0.5); Прикольный эффект как шарики вместо пикселей
//    result:=sin(t*3.1415927*0.5);
//  end;   // GetPixel - функция возвращает цвет пиксела в текстуре координаты которого
// заданы вещественными числами (fx,fy), при этом учитывается, что текстура
// зациклена в области (0,0)-(1,1) - все выпадающие значения беруться из этой
 // области
 //  k1:=cosint(1-dx)*cosint(1-dy); k2:=cosint(dx)*cosint(1-dy);
 //  k3:=cosint(1-dx)*cosint(dy); k4:=cosint(dx)*cosint(dy);
function TTextureGenerator.GetPixel(fx, fy: single): TRGBAColor; // 0<=fx,fy<=1 -
var
  ix, iy, jx, jy, aa, ab, ac, ad: integer;
  //  x, y, dx, dy, k1, k2, k3, k4:   single;
  x0, y0, x1, y1:     integer;
  dx0, dy0, x, y:     single;
  c00, c10, c01, c11: TRGBAColor;
begin
  if not IsLoaded then
  begin
    Result.Eqv(0, 0, 0, 1);
    exit;
  end;
  while fx < 0 do
    fx := fx + 100;
  while fy < 0 do
    fy := fy + 100;

  x := fx * Width;
  y := fy * Height;

  x0 := trunc(x) mod Width;
  x1 := (x0 + 1) mod Width;
  y0 := trunc(y) mod Height;
  y1 := (y0 + 1) mod Height;

  dx0 := x - trunc(x);
  dy0 := y - trunc(y);

  c00 := rgba^[Width * y0 + x0];
  c10 := rgba^[Width * y0 + x1];
  c01 := rgba^[Width * y1 + x0];
  c11 := rgba^[Width * y1 + x1];

  Result.r := lerp(lerp(c00.r, c10.r, dx0), lerp(c01.r, c11.r, dx0), dy0);
  Result.g := lerp(lerp(c00.g, c10.g, dx0), lerp(c01.g, c11.g, dx0), dy0);
  Result.b := lerp(lerp(c00.b, c10.b, dx0), lerp(c01.b, c11.b, dx0), dy0);
  Result.a := lerp(lerp(c00.a, c10.a, dx0), lerp(c01.a, c11.a, dx0), dy0);

{   !!! do not work
  Result.r := cerp(cerp(c00.r, c10.r, dx0), cerp(c01.r, c11.r, dx0), dy0);
  Result.g := cerp(cerp(c00.g, c10.g, dx0), cerp(c01.g, c11.g, dx0), dy0);
  Result.b := cerp(cerp(c00.b, c10.b, dx0), cerp(c01.b, c11.b, dx0), dy0);
  Result.a := cerp(cerp(c00.a, c10.a, dx0), cerp(c01.a, c11.a, dx0), dy0);
 }
end;

{******************************************************************************}
procedure TTextureGenerator.SetNewBitmap;
begin
  //  if rgba<>nil then GlobalFree(LongWord(rgba));
  //  rgba:=Pointer(GlobalAlloc(0,Width*Height*4*4));
  //if rgba<>nil then FreeMem(rgba);
  ReAllocMem(rgba, Width * Height * 4 * 4);
  //  AllocMem(rgba,Width*Height*4*4);
  FillMemory(rgba, Width * Height * 4 * 4, 0);
  WidthMul  := Width * $FFFF;
  HeightMul := Height * $FFFF;
  IsLoaded  := True;
end;

{******************************************************************************}
procedure TTextureGenerator.SetFrom(tg: TTextureGenerator);
var
  i: integer;
begin
  if rgba = nil then
    SetNewBitmap;
  if (Width <> tg.Width) or (Height <> tg.Height) or (tg.rgba = nil) then
    exit;
  for i := 0 to Width * Height - 1 do
  begin  // Сука из за этой -1 убил 5 дней БЛЯ!!!!
    rgba^[i] := tg.rgba^[i];
  end;
end;

{******************************************************************************}
constructor TTextureGenerator.Create;
begin
  texID:=0;
  Width    := 512;
  Height   := 512;
  rbm      := nil;
  rgba     := nil;
  IsLoaded := False;
  IsCached := False;
  IsCachedGL := False;
  format:=0;//GL_RGBA8;
  wrapType:=0;//GL_REPEAT;
  //wrapType:=GL_CLAMP;
  filterType:=0;//GL_LINEAR;
  //  filterType:=GL_NEAREST;
  colourType:=0;//GL_MODULATE;
  //  colourType:=GL_REPLACE;
  mipmap   := 1;
end;

{******************************************************************************}
destructor TTextureGenerator.Destroy;
begin
  UnCacheGL;
  UnCache;
  if rgba <> nil then FreeMem(rgba);
end;

procedure TTextureGenerator.OnInitContext;
begin
  CacheGL;
end;

procedure TTextureGenerator.OnDestroyContext;
begin
  UnCacheGL;
end;


{*******************************************************************************
                                 PRIMITIVE
*******************************************************************************}
procedure TTextureGenerator.Primitive_Rect(x1, y1, x2, y2: integer; r, g, b, a: single);
var
  x, y, adr: integer;
begin
  if rgba = nil then
    SetNewBitmap;
  if x2 <= x1 then
    exit;
  if y2 <= y1 then
    exit;
  for y := y1 to y2 do
  begin
    adr := (DWord(y) mod Height) * Width;
    for x := x1 to x2 do
    begin
      {$R-}
      rgba^[adr + (DWord(x) mod Width)].Eqv(r, g, b, a);
      {$R+}
    end;
  end;
end;

{******************************************************************************}
procedure TTextureGenerator.Primitive_ZCircle(px, py, sx, sy: integer;
  irrx, irry: single);
var
  i, j:      integer;
  adr, adrr: cardinal;
  rx, ry, tx, ty, drx, dry, c, a: single;
begin
  if rgba = nil then
    SetNewBitmap;
  drx := 1 / sx;
  dry := 1 / sy;
  ry  := -1;
  a   := 45 * PI / 180 + irrx;
  for j := -sy to sy do
  begin
    adr := (cardinal(j + py) mod Height) * Width;
    rx  := -1;
    for i := -sx to sx do
    begin
      adrr := adr + (cardinal(i + px) mod Width);
      tx   := rx * sin(a) - ry * cos(a);
      ty   := rx * cos(a) + ry * sin(a);
      c    := 1 - sqrt(tx * tx + ty * ty);
      if c < 0 then
        c := 0;
      if rgba^[adrr].a < c then
      begin
        rgba^[adrr].r := c;
        rgba^[adrr].a := c;
      end;
      rx := rx + drx;
    end;
    ry := ry + dry;
  end;
end;

{******************************************************************************}
procedure TTextureGenerator.Primitive_ZCell(px, py, sx, sy: integer; irrx, irry: single);
var
  i, j:      integer;
  adr, adrr: cardinal;
  rx, ry, tx, ty, drx, dry, c, a: single;
begin
  if rgba = nil then
    SetNewBitmap;
  drx := 1 / sx;
  dry := 1 / sy;
  ry  := -1;
  a   := 45 * PI / 180;
  for j := -sy to sy do
  begin
    adr := (cardinal(j + py) mod Height) * Width;
    rx  := -1;
    for i := -sx to sx do
    begin
      adrr := adr + (cardinal(i + px) mod Width);
      tx   := rx * sin(a + irrx) - ry * cos(a + irry);
      ty   := ry * cos(a + irrx) + rx * sin(a + irry);
      c    := 1 - abs(tx) - abs(ty);
      if c < 0 then
        c := 0;
      if rgba^[adrr].a < c then
      begin
        rgba^[adrr].a := c;
        if c < 0.7 then
        begin
          c := 0.7 * (c / 0.7) * (c / 0.7) * (c / 0.7);
        end
        else
          c := 1 - abs(tx) - abs(ty);
        rgba^[adrr].r := c;
      end;
      rx := rx + drx;
    end;
    ry := ry + dry;
  end;
end;

{******************************************************************************}
procedure TTextureGenerator.Primitive_ZSquare(px, py, sx, sy: integer;
  irrx, irry: single);
var
  i, j:      integer;
  adr, adrr: cardinal;
  rx, ry, tx, ty, drx, dry, c, a: single;
begin
  if rgba = nil then
    SetNewBitmap;
  drx := 1 / sx;
  dry := 1 / sy;
  ry  := -1;
  a   := irrx + 45 * PI / 180;
  for j := -sy to sy do
  begin
    adr := (cardinal(j + py) mod Height) * Width;
    rx  := -1;
    for i := -sx to sx do
    begin
      adrr := adr + (cardinal(i + px) mod Width);
      tx   := rx * sin(a) - ry * cos(a);
      ty   := rx * cos(a) + ry * sin(a);
      c    := 1 - abs(tx) - abs(ty);
      if rgba^[adrr].a < c then
      begin
        rgba^[adrr].r := c;
        rgba^[adrr].a := c;
      end;
      rx := rx + drx;
    end;
    ry := ry + dry;
  end;
end;

{******************************************************************************}
procedure TTextureGenerator.Primitive_ZTechAlpha(px, py, sx, sy: integer;
  irrx, irry: single);
var
  i, j:      integer;
  adr, adrr: cardinal;
  rx, ry, tx, ty, drx, dry, c, a: single;
begin
  if rgba = nil then
    SetNewBitmap;
  drx := 1 / sx;
  dry := 1 / sy;
  ry  := -1;
  a   := irrx + 45 * PI / 180;
  for j := -sy to sy do
  begin
    adr := (cardinal(j + py) mod Height) * Width;
    rx  := -1;
    for i := -sx to sx do
    begin
      adrr := adr + (cardinal(i + px) mod Width);
      tx   := rx * sin(a) - ry * cos(a);
      ty   := rx * cos(a) + ry * sin(a);
      c    := sin(abs(tx) * abs(ty));
      if rgba^[adrr].a < c then
      begin
        rgba^[adrr].r := c;
        rgba^[adrr].a := c;
      end;
      rx := rx + drx;
    end;
    ry := ry + dry;
  end;
end;

{******************************************************************************}
procedure TTextureGenerator.Primitive_ZStar(px, py, sx, sy: integer; irrx, irry: single);
var
  i, j:      integer;
  adr, adrr: cardinal;
  rx, ry, tx, ty, drx, dry, c, a: single;
begin
  if rgba = nil then
    SetNewBitmap;
  drx := 1 / sx;
  dry := 1 / sy;
  ry  := -1;
  a   := irrx + 45 * PI / 180;
  for j := -sy to sy do
  begin
    adr := (cardinal(j + py) mod Height) * Width;
    rx  := -1;
    for i := -sx to sx do
    begin
      adrr := adr + (cardinal(i + px) mod Width);
      tx   := rx * sin(a) - ry * cos(a);
      ty   := rx * cos(a) + ry * sin(a);
      c    := (1 - abs(ty)) * (1 - abs(tx));
      if rgba^[adrr].a < c then
      begin
        rgba^[adrr].r := c;
        rgba^[adrr].a := c;
      end;
      rx := rx + drx;
    end;
    ry := ry + dry;
  end;
end;

{******************************************************************************}
procedure TTextureGenerator.Primitive_ZSinSquare(px, py, sx, sy: integer; irrx, irry: single);
var
  i, j:      integer;
  adr, adrr: cardinal;
  rx, ry, tx, ty, drx, dry, c, a: single;
begin
  if rgba = nil then
    SetNewBitmap;
  drx := 1 / sx;
  dry := 1 / sy;
  ry  := -1;
  a   := irrx + 45 * PI / 180;
  for j := -sy to sy do
  begin
    adr := (cardinal(j + py) mod Height) * Width;
    rx  := -1;
    for i := -sx to sx do
    begin
      adrr := adr + (cardinal(i + px) mod Width);
      tx   := rx * sin(a) - ry * cos(a);
      ty   := rx * cos(a) + ry * sin(a);
      c    := 1 / (tx * tx + 1 + ty * ty);
      if rgba^[adrr].a < c then
      begin
        rgba^[adrr].r := c;
        rgba^[adrr].a := c;
      end;
      rx := rx + drx;
    end;
    ry := ry + dry;
  end;
end;

 {******************************************************************************}
 // RadRect
procedure TTextureGenerator.Primitive_RadRect(px, py, Iterations: integer;
  r, g, b, a: single);
var
  i, j:      integer;
  rr, rc, cc: single;
  adr, adrr: cardinal;
begin
  if rgba = nil then
    SetNewBitmap;
  rr := Iterations * Iterations;
  for j := -Iterations to Iterations do
  begin
    adr := (cardinal(j + py) mod Height) * Width;
    for i := -Iterations to Iterations do
    begin
      rc := sqrt(i * i / rr + j * j / rr);
      if rc < 1 then
      begin
        adrr := adr + (cardinal(i + px) mod Width);
        cc   := Cos(0.5 * PI * rc);
        rgba^[adrr].Eqv(cc * r, cc * g, cc * b, cc * a);
      end;
    end;
  end;
end;

{*******************************************************************************
                                  GENERATE
*******************************************************************************}
// Bricks
procedure TTextureGenerator.Generate_Bricks(w, h: integer;
  border, shifts, widthvariation, slidevariation: single; rootseed: cardinal);
var
  i, j, x1, y1, x2, y2: integer;
  dx, dy, bs, dsx, accsx, slide, widthvar, widthvaracc: single;
begin
  SetNewBitmap;
  if w <= 0 then
    w := 1;
  if h <= 0 then
    h   := 1;
  dx    := Width/w;
  dy    := Height/h;
  dsx   := dx * shifts;
  bs    := border * dx;
  accsx := 0;
  for j := 0 to h - 1 do
  begin
    slide := dx * GetNoise1d(rootseed, j) * slidevariation;
    widthvaracc := 0;
    for i := 0 to w - 1 do
    begin
      if i < w - 1 then
        widthvar := dx * GetNoise2d(rootseed, i, j) * widthvariation
      else
        widthvar := Width - (i + 1) * dx - widthvaracc;
      x1 := round(i * dx + bs + accsx + slide + widthvaracc);
      y1 := round(j * dy + bs);
      x2 := round((i + 1) * dx - bs + accsx + slide + widthvaracc + widthvar);
      y2 := round((j + 1) * dy - bs);
      Primitive_Rect(x1, y1, x2, y2, 1, 0, 0, 1);
      widthvaracc := widthvaracc + widthvar;
    end;
    accsx := accsx + dsx;
  end;
end;

 {******************************************************************************}
 // Generate_Gradient - генерация градиента на текстуре
 // w,h - количество сэмплов по осям
// gradient - тип градиента ( 0 - горизонтальный, 1 - вертикальный, ...
procedure TTextureGenerator.Generate_Gradient(w, h, gradient: integer;
  rootseed: cardinal);
var
  x, y, adr, iw, ih:  integer;
  tw, th, rx, ry, rr: single;
begin
  SetNewBitmap;

  if gradient = 0 then
  begin
    // Горизонтальный
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;
    adr  := 0;
    for y := 0 to Height - 1 do
    begin
      for x := 0 to Width - 1 do
      begin
        rgba^[adr].r := (x mod iw) / iw;
        Inc(adr);
      end;
    end;
  end
  else if gradient = 1 then
  begin
    // вертикальный
    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;
    adr  := 0;
    for y := 0 to Height - 1 do
    begin
      rr := (y mod ih) / ih;
      for x := 0 to Width - 1 do
      begin
        rgba^[adr].r := rr;
        Inc(adr);
      end;
    end;
  end
  else if gradient = 2 then
  begin
    // радиальный острый
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := (2 * ((y mod ih) - ih / 2) / ih);
      ry := ry * ry;
      for x := 0 to Width - 1 do
      begin
        rx := (2 * ((x mod iw) - iw / 2) / iw);
        rx := rx * rx;
        rgba^[adr].r := 1 - sqrt(sqrt(rx + ry));
        if rgba^[adr].r < 0 then
          rgba^[adr].r := 0;
        Inc(adr);
      end;
    end;
  end
  else if gradient = 3 then
  begin
    // радиальный шар
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := 2 * ((y mod ih) - ih / 2) / ih;
      ry := ry * ry;
      for x := 0 to Width - 1 do
      begin
        rx := 2 * ((x mod iw) - iw / 2) / iw;
        rx := rx * rx;
        rgba^[adr].r := 1 - sqrt(rx + ry);
        if rgba^[adr].r < 0 then
          rgba^[adr].r := 0;
        Inc(adr);
      end;
    end;
  end
  else if gradient = 4 then
  begin
    // радиальный пологий
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := (2 * ((y mod ih) - ih / 2) / ih);
      ry := ry * ry;
      for x := 0 to Width - 1 do
      begin
        rx := (2 * ((x mod iw) - iw / 2) / iw);
        rx := rx * rx;
        rgba^[adr].r := 1 - rx - ry;
        if rgba^[adr].r < 0 then
          rgba^[adr].r := 0;
        Inc(adr);
      end;
    end;
  end
  else if gradient = 5 then
  begin
    // рельефный
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := (2 * ((y mod ih) - ih / 2) / ih);
      ry := ry * ry;
      for x := 0 to Width - 1 do
      begin
        rx := (2 * ((x mod iw) - iw / 2) / iw);
        rx := rx * rx;
        rgba^[adr].r := abs(ry - rx);
        if rgba^[adr].r < 0 then
          rgba^[adr].r := 0;
        Inc(adr);
      end;
    end;
  end
  else if gradient = 6 then
  begin
    // радиальный синусовый
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := sin(2 * PI * (2 * ((y mod ih) - ih / 2) / ih));
      for x := 0 to Width - 1 do
      begin
        rx := sin(2 * PI * (2 * ((x mod iw) - iw / 2) / iw));
        rgba^[adr].r := abs(rx * ry);
        Inc(adr);
      end;
    end;
  end
  else if gradient = 7 then
  begin
    // Вертикальная полоса
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := 2 * ((y mod ih) - ih / 2) / ih;
      for x := 0 to Width - 1 do
      begin
        rx := 2 * ((x mod iw) - iw / 2) / iw;
        rgba^[adr].r := 1 - abs(rx);
        Inc(adr);
      end;
    end;
  end
  else if gradient = 8 then
  begin
    // Горизонтальная полоса
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := 2 * ((y mod ih) - ih / 2) / ih;
      for x := 0 to Width - 1 do
      begin
        rx := 2 * ((x mod iw) - iw / 2) / iw;
        rgba^[adr].r := 1 - abs(ry);
        Inc(adr);
      end;
    end;
  end
  else if gradient = 9 then
  begin
    // звезда
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := 2 * ((y mod ih) - ih / 2) / ih;
      for x := 0 to Width - 1 do
      begin
        rx := 2 * ((x mod iw) - iw / 2) / iw;
        rgba^[adr].r := (1 - abs(ry)) * (1 - abs(rx));
        Inc(adr);
      end;
    end;
  end
  else if gradient = 10 then
  begin
    // звезда маленькая
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := 2 * ((y mod ih) - ih / 2) / ih;
      for x := 0 to Width - 1 do
      begin
        rx := 2 * ((x mod iw) - iw / 2) / iw;
        rr := (1 - abs(ry)) * (1 - abs(rx));
        rgba^[adr].r := rr * rr;
        Inc(adr);
      end;
    end;
  end
  else if gradient = 11 then
  begin
    // танцпол с подсветкой
    if w <= 0 then
      w := 1;
    iw  := Width div w;
    if iw <= 0 then
      iw := 1;

    if h <= 0 then
      h := 1;
    ih  := Height div h;
    if ih <= 0 then
      ih := 1;

    adr := 0;
    for y := 0 to Height - 1 do
    begin
      ry := 2 * ((y mod ih) - ih / 2) / ih;
      for x := 0 to Width - 1 do
      begin
        rx := 2 * ((x mod iw) - iw / 2) / iw;
        rgba^[adr].r := 1 / (rx * rx + 1 + ry * ry);
        Inc(adr);
      end;
    end;
  end;
end;

 {******************************************************************************}
 // Generate_Noise - генерация случайного шума
 // w,h - размеры семпла шума должны быть кратны 2
// filter - способ интерполяции (0 - линейная, 1-косинусовая)
// iterations - количество подшумов с меньшей амплитудой (как в perling)
procedure TTextureGenerator.Generate_Noise(w, h: integer;
  filter, iterations: integer; intensity, distortion: single; rootseed: cardinal);

var
  Iteration, TurbulenceSizeX, TurbulenceSizeY: integer;
  r_seed, d_seed: cardinal;

  function GenNoise0(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);// dx1:=dx0-1;
    dy0 := y - trunc(y);// dy1:=dy0-1;

    n00 := GetNoise3d(r_seed, x0, y0, Iteration); //if n00<0 then n00:=0 else n00:=1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration); //if n01<0 then n01:=0 else n01:=1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration); //if n10<0 then n10:=0 else n10:=1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration); //if n11<0 then n11:=0 else n11:=1;

    Result := lerp(lerp(n00, n10, dx0), lerp(n01, n11, dx0), dy0) * 0.5 + 0.5;
  end;

  function GenNoise1(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);// dx1:=dx0-1;
    dy0 := y - trunc(y);// dy1:=dy0-1;
    {$R-}
    n00 := GetNoise3d(r_seed, x0, y0, Iteration); //if n00<0 then n00:=0 else n00:=1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration); //if n01<0 then n01:=0 else n01:=1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration); //if n10<0 then n10:=0 else n10:=1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration); //if n11<0 then n11:=0 else n11:=1;
    {$R+}

    Result := cerp(cerp(n00, n10, dx0), cerp(n01, n11, dx0), dy0) * 0.5 + 0.5;
  end;

  function GenNoise2(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);
    dx1 := dx0 - 1;
    dy0 := y - trunc(y);
    dy1 := dy0 - 1;

    n00 := GetNoise3d(r_seed, x0, y0, Iteration);
    n01 := GetNoise3d(r_seed, x0, y1, Iteration);
    n10 := GetNoise3d(r_seed, x1, y0, Iteration);
    n11 := GetNoise3d(r_seed, x1, y1, Iteration);

    sx := dx0 * dx0 * (3 - 2 * dx0);
    sy := dy0 * dy0 * (3 - 2 * dy0);

    u := (dx0 + dy0) * n00;
    v := (dx1 + dy0) * n10;
    a := u + sx * (v - u);
    u := (dx0 + dy1) * n01;
    v := (dx1 + dy1) * n11;
    b := u + sx * (v - u);

    Result := (a + sy * (b - a)) * 0.5 + 0.5;
  end;

  function GenNoise3(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);
    dx1 := dx0 - 1;
    dy0 := y - trunc(y);
    dy1 := dy0 - 1;

    n00 := GetNoise3d(r_seed, x0, y0, Iteration);
    if n00 < 0.5 then
      n00 := 0
    else
      n00 := 1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration);
    if n01 < 0.5 then
      n01 := 0
    else
      n01 := 1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration);
    if n10 < 0.5 then
      n10 := 0
    else
      n10 := 1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration);
    if n11 < 0.5 then
      n11 := 0
    else
      n11 := 1;

    sx := dx0 * dx0 * (3 - 2 * dx0);
    sy := dy0 * dy0 * (3 - 2 * dy0);

    u := (dx0 + dy0) * n00;
    v := (dx1 + dy0) * n10;
    a := u + sx * (v - u);
    u := (dx0 + dy1) * n01;
    v := (dx1 + dy1) * n11;
    b := u + sx * (v - u);

    Result := (a + sy * (b - a)) * 0.5 + 0.5;
    //    result:=(dx1*dy1*n00+dx0*dy1*n10+dx1*dy0*n01+dx0*dy0*n11)/4;
  end;

  function GenNoise4(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);
    dx1 := dx0 - 1;
    dy0 := y - trunc(y);
    dy1 := dy0 - 1;

    n00 := GetNoise3d(r_seed, x0, y0, Iteration);
    if n00 < 0 then
      n00 := 0
    else
      n00 := 1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration);
    if n01 < 0 then
      n01 := 0
    else
      n01 := 1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration);
    if n10 < 0 then
      n10 := 0
    else
      n10 := 1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration);
    if n11 < 0 then
      n11 := 0
    else
      n11 := 1;

    sx := dx0;//*dx0*(3-2*dx0);
    sy := dy0;//*dy0*(3-2*dy0);

    u := (dx0 + dy0) * n00;
    v := (dx1 + dy0) * n10;
    a := u + sx * (v - u);
    u := (dx0 + dy1) * n01;
    v := (dx1 + dy1) * n11;
    b := u + sx * (v - u);

    Result := abs(a + sy * (b - a));//*0.5+0.5;
    //    result:=(dx1*dy1*n00+dx0*dy1*n10+dx1*dy0*n01+dx0*dy0*n11)/4;
  end;

  function GenNoise5(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);
    dx1 := dx0 - 1;
    dy0 := y - trunc(y);
    dy1 := dy0 - 1;

    n00 := GetNoise3d(r_seed, x0, y0, Iteration); //if n00<0 then n00:=0 else n00:=1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration); //if n01<0 then n01:=0 else n01:=1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration); //if n10<0 then n10:=0 else n10:=1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration); //if n11<0 then n11:=0 else n11:=1;

    sx := dx0 * dx0 * (3 - 2 * dx0);
    sy := dy0 * dy0 * (3 - 2 * dy0);

    u := (dx0 + dy0) * n00;
    v := (dx1 + dy0) * n10;
    a := u + sx * (v - u);
    u := (dx0 + dy1) * n01;
    v := (dx1 + dy1) * n11;
    b := u + sx * (v - u);

    Result := abs(a + sy * (b - a));//*0.5+0.5;
    //    result:=(dx1*dy1*n00+dx0*dy1*n10+dx1*dy0*n01+dx0*dy0*n11)/4;
  end;

  function GenNoise6(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);// dx1:=dx0-1;
    dy0 := y - trunc(y);// dy1:=dy0-1;

    n00 := GetNoise3d(r_seed, x0, y0, Iteration); //if n00<0 then n00:=0 else n00:=1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration); //if n01<0 then n01:=0 else n01:=1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration); //if n10<0 then n10:=0 else n10:=1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration); //if n11<0 then n11:=0 else n11:=1;

    Result := abs(lerp(lerp(n00, n10, dx0), lerp(n01, n11, dx0), dy0));
  end;

  function GenNoise7(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);// dx1:=dx0-1;
    dy0 := y - trunc(y);// dy1:=dy0-1;

    n00 := GetNoise3d(r_seed, x0, y0, Iteration); //if n00<0 then n00:=0 else n00:=1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration); //if n01<0 then n01:=0 else n01:=1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration); //if n10<0 then n10:=0 else n10:=1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration); //if n11<0 then n11:=0 else n11:=1;

    Result := abs(cerp(cerp(n00, n10, dx0), cerp(n01, n11, dx0), dy0));
  end;

  function GenNoise8(x, y: single): single;
  var
    x0, x1, y0, y1: integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b, n00, n01, n10, n11: single;
    b00, b10, b01, b11: integer;
    n1, n2: single;
  begin
    x0 := trunc(x) mod TurbulenceSizeX;
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);// dx1:=dx0-1;
    dy0 := y - trunc(y);// dy1:=dy0-1;

    n00 := GetNoise3d(r_seed, x0, y0, Iteration * 10);
    //if n00<0 then n00:=0 else n00:=1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration * 10);
    //if n01<0 then n01:=0 else n01:=1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration * 10);
    //if n10<0 then n10:=0 else n10:=1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration * 10);
    //if n11<0 then n11:=0 else n11:=1;

    n1 := (cerp(cerp(n00, n10, dx0), cerp(n01, n11, dx0), dy0));

    n00 := GetNoise3d(r_seed, x0, y0, Iteration * 10 + 1);
    //if n00<0 then n00:=0 else n00:=1;
    n01 := GetNoise3d(r_seed, x0, y1, Iteration * 10 + 1);
    //if n01<0 then n01:=0 else n01:=1;
    n10 := GetNoise3d(r_seed, x1, y0, Iteration * 10 + 1);
    //if n10<0 then n10:=0 else n10:=1;
    n11 := GetNoise3d(r_seed, x1, y1, Iteration * 10 + 1);
    //if n11<0 then n11:=0 else n11:=1;

    n2 := (cerp(cerp(n00, n10, dx0), cerp(n01, n11, dx0), dy0));

    Result := (arcsin(n2) / (2 * PI) + 0.5) * (arccos(n1) / (2 * PI) + 0.5);
    //cos(5*cos(x)+3*cos(y)+PI*3)+cos(cos(x)+2*cos(y)+PI*6);

    //    result:=trunc(*5);
    //    result:=sin(2*PI*x)*cos(2*PI*y)*0.5+0.5;//
  end;

var
  i, j: integer;
  n00, n10, n01, n11, n1, n2, fx, fy, dx0, dy0: single;
  x, y, nx, ny, adr, k, x0, x1, y0, y1: integer;

  freq: single;
begin
  SetNewBitmap;
  if w <= 0 then
    w := 1;
  if h <= 0 then
    h := 1;
  if w > Width then
    w := Width;
  if h > Height then
    h := Height;
  if iterations <= 0 then
    iterations := 1;
  for i := 0 to Width * Height - 1 do
    rgba^[i].r := 0;
  freq := intensity;
  TurbulenceSizeX := w;
  TurbulenceSizeY := h;
  for Iteration := 0 to iterations do
  begin
    r_seed := rootseed;
    d_seed := rootseed + 100;
    for j := 0 to Height - 1 do
    begin
      for i := 0 to Width - 1 do
      begin
        adr := i + j * Width;

        fx := TurbulenceSizeX * i / Width;
        fy := TurbulenceSizeY * j / Height;

        if distortion > 0.00001 then
        begin
          x0 := trunc(fx) mod (TurbulenceSizeX);
          x1 := (x0 + 1) mod (TurbulenceSizeX);
          y0 := trunc(fy) mod (TurbulenceSizeY);
          y1 := (y0 + 1) mod (TurbulenceSizeY);

          dx0 := fx - trunc(fx);
          dy0 := fy - trunc(fy);

          n00 := GetNoise3d(d_seed, x0, y0, Iteration);
          n01 := GetNoise3d(d_seed, x0, y1, Iteration);
          n10 := GetNoise3d(d_seed, x1, y0, Iteration);
          n11 := GetNoise3d(d_seed, x1, y1, Iteration);
          n1  := (cerp(cerp(n00, n10, dx0), cerp(n01, n11, dx0), dy0));

          fx := fx + distortion * sin(n1 * PI);
          if fx < 0 then
            fx := fx + TurbulenceSizeX;
          fy   := fy + distortion * sin(n1 * PI);
          if fy < 0 then
            fy := fy + TurbulenceSizeY;
        end;

        case filter of
          0: rgba^[adr].r := rgba^[adr].r + GenNoise0(fx, fy) * freq;
          1: rgba^[adr].r := rgba^[adr].r + GenNoise1(fx, fy) * freq;
          2: rgba^[adr].r := rgba^[adr].r + GenNoise2(fx, fy) * freq;
          3: rgba^[adr].r := rgba^[adr].r + GenNoise3(fx, fy) * freq;
          4: rgba^[adr].r := rgba^[adr].r + GenNoise4(fx, fy) * freq;
          5: rgba^[adr].r := rgba^[adr].r + GenNoise5(fx, fy) * freq;
          6: rgba^[adr].r := rgba^[adr].r + GenNoise6(fx, fy) * freq;
          7: rgba^[adr].r := rgba^[adr].r + GenNoise7(fx, fy) * freq;
          8: rgba^[adr].r := rgba^[adr].r + GenNoise8(fx, fy) * freq;
        end;

      end;
    end;
    freq := freq * 0.5;
    TurbulenceSizeX := TurbulenceSizeX * 2;
    TurbulenceSizeY := TurbulenceSizeY * 2;
    if (TurbulenceSizeX > Width) and (TurbulenceSizeY > Height) then
      break;
  end;
end;

{******************************************************************************}
procedure TTextureGenerator.Generate_Turbulence(rootseed: cardinal;
  w, h, Iterations: integer);
var
  j, i, k, l, t: integer;
  x, y, freq: single;
  r_seed, rr_seed, adr: cardinal;
  P: array of integer;

  TurbulenceWidth, TurbulenceHeight:    integer;
  TurbulenceOffsetX, TurbulenceOffsetY: single;
  TurbulenceSizeX, TurbulenceSizeY:     integer;

  function TurbulenceNoise2D(x, y: single): single;
  var
    x0, x1, y0, y1:     integer;
    dx0, dx1, dy0, dy1: single;
    sx, sy, u, v, a, b: single;
    b00, b10, b01, b11: integer;
  begin
    x0 := trunc(x) mod TurbulenceSizeX; //Turbulence
    x1 := (x0 + 1) mod TurbulenceSizeX;
    y0 := trunc(y) mod TurbulenceSizeY;
    y1 := (y0 + 1) mod TurbulenceSizeY;

    dx0 := x - trunc(x);
    dx1 := dx0 - 1;
    dy0 := y - trunc(y);
    dy1 := dy0 - 1;

    // Replacer
    b00 := P[P[x0] + y0];
    b10 := P[P[x1] + y0];
    b01 := P[P[x0] + y1];
    b11 := P[P[x1] + y1];


    sx := dx0 * dx0 * (3 - 2 * dx0);
    sy := dy0 * dy0 * (3 - 2 * dy0);

    u      := dx0 * GetNoise2d(r_seed, b00, 0) + dy0 * GetNoise2d(r_seed, b00, 1);
    v      := dx1 * GetNoise2d(r_seed, b10, 0) + dy0 * GetNoise2d(r_seed, b10, 1);
    a      := u + sx * (v - u);
    u      := dx0 * GetNoise2d(r_seed, b01, 0) + dy1 * GetNoise2d(r_seed, b01, 1);
    v      := dx1 * GetNoise2d(r_seed, b11, 0) + dy1 * GetNoise2d(r_seed, b11, 1);
    b      := u + sx * (v - u);
    Result := a + sy * (b - a);
  end;

begin
  SetNewBitmap;
  TurbulenceWidth := w;
  TurbulenceHeight := h;
  TurbulenceOffsetX := 0;
  TurbulenceOffsetY := 0;
  r_seed := rootseed;

  // Init
  for j := 0 to Height - 1 do begin
    for i := 0 to Width - 1 do begin
      adr := i + j * Width;
      rgba^[adr].r := 0;
    end;
  end;


  freq := 1;
  TurbulenceSizeX := TurbulenceWidth;
  TurbulenceSizeY := TurbulenceHeight;
  for k := Iterations downto 0 do begin

    SetLength(P, TurbulenceSizeX + TurbulenceSizeY + 2);
    for i := 0 to TurbulenceSizeX - 1 do
      P[i] := i;

    r_seed   := rootseed;
    for l := 0 to 2 do
      for i := 0 to TurbulenceSizeX - 1 do begin
        j    := irandom(r_seed, TurbulenceSizeX);
        t    := P[i];
        P[i] := P[j];
        P[j] := t;
      end;

    for i := 0 to TurbulenceSizeY + 1 do P[TurbulenceSizeX + i] := P[i];

    r_seed := rootseed;

    // Turbulence
    for j := 0 to Height - 1 do
    begin
      for i := 0 to Width - 1 do
      begin
        adr := i + j * Width;
        x   := TurbulenceSizeX * i / Width + TurbulenceOffsetX;
        y   := TurbulenceSizeY * j / Height + TurbulenceOffsetY;
        rgba^[adr].r := rgba^[adr].r + abs(TurbulenceNoise2D(x, y)) * freq;
        x   := x * 2;
        y   := y * 2;
      end;
    end;
    freq := freq * 0.5;
    TurbulenceSizeX := TurbulenceSizeX * 2;
    TurbulenceSizeY := TurbulenceSizeY * 2;

    P:=nil;
  end;
  

  for j := 0 to Height - 1 do
  begin
    for i := 0 to Width - 1 do
    begin
      adr := i + j * Width;
      rgba^[adr].g := rgba^[adr].r;
      rgba^[adr].b := rgba^[adr].r;
      rgba^[adr].a := 1;
    end;
  end;

end;

 {******************************************************************************}
 // SolidColor
procedure TTextureGenerator.Generate_SolidColor(r, g, b, a: single);
var
  i: integer;
  p: TRGBAColor;
begin
  SetNewBitmap;
  p.r := r;
  p.g := g;
  p.b := b;
  p.a := a;
  for i := 0 to Width * Height - 1 do
    rgba^[i] := p;
end;

 {******************************************************************************}
 // Plasma
procedure TTextureGenerator.Generate_Plasma(w, h: integer; rootseed: cardinal);
var
  x, y: integer;
  xc, yc, c1, c2, s1, s2, s3, s: single;
  p:    TRGBAColor;
begin
  SetNewBitmap;
  xc := 25;
  c1 := sin(0.3);
  c2 := sin(0.4);
  for x := 0 to Width - 1 do
  begin
    yc := 25;
    s1 := 128 + 128 * sin(PI * xc * c1 / 180);
    for y := 0 to Height - 1 do
    begin
      s2 := 128 + 128 * sin(PI * yc * c2 / 180);
      s3 := 128 + 128 * sin(PI * (-xc - yc + 0.3) / 360);
      s  := (s1 + s2 + s3) / 3;
      rgba^[Width * y + x].Eqv(s / 255, 0{(255-s/2)/255}, 0, 0);
      yc := yc + 3;
    end;
    xc := xc + 3;
  end;
end;

 {******************************************************************************}
 // Cells
procedure TTextureGenerator.Generate_Cells(w, h, squaretype: integer;
  irregularity, distribution, scale: single; rootseed: cardinal);

var
  x, y, z: integer;
  celw, celh, irr: single;
  dist:    single;
begin
  SetNewBitmap;
  for y := 0 to Height - 1 do
  begin
    for x := 0 to Width - 1 do
    begin
      rgba^[y * Width + x].Eqv(0, 0, 0, 0);
    end;
  end;
  if scale < 0.1 then
    scale := 0.01;

  if w <= 0 then
    w := 1;
  if h <= 0 then
    h := 1;

  celw := Width / w;
  celh := Height / h;

  if round(2 * celw * scale) <= 0 then
    scale := 1 / (2 * celw - 1);
  if round(2 * celh * scale) <= 0 then
    scale := 1 / (2 * celh - 1);

  irr := irregularity;
  for x := 0 to w - 1 do
  begin
    for y := 0 to h - 1 do
    begin
      case squaretype of
        0: Primitive_ZSquare(round(x * celw + celw / 2 + distribution *
            GetFloatRnd(rootseed) * celw), round(y * celh + celh /
            2 + distribution * GetFloatRnd(rootseed) * celh),
            round(2 * celw * scale), round(2 * celh * scale),
            PI * GetFloatRnd(rootseed) * irr, PI * GetFloatRnd(rootseed) * irr);
        1: Primitive_ZCell(round(x * celw + celw / 2 + distribution *
            GetFloatRnd(rootseed) * celw),
            round(y * celh + celh / 2 + distribution * GetFloatRnd(rootseed) * celh),
            round(2 * celw * scale), round(2 * celh * scale), PI *
            GetFloatRnd(rootseed) * irr, PI * GetFloatRnd(rootseed) * irr);
        2: Primitive_ZCircle(round(x * celw + celw / 2 + distribution *
            GetFloatRnd(rootseed) * celw), round(y * celh + celh /
            2 + distribution * GetFloatRnd(rootseed) * celh),
            round(2 * celw * scale), round(2 * celh * scale),
            PI * GetFloatRnd(rootseed) * irr, PI * GetFloatRnd(rootseed) * irr);
        3: Primitive_ZTechAlpha(
            round(x * celw + celw / 2 + distribution * GetFloatRnd(rootseed) * celw),
            round(y * celh + celh / 2 + distribution * GetFloatRnd(rootseed) * celh),
            round(celw * scale), round(celh * scale), PI *
            GetFloatRnd(rootseed) * irr, PI * GetFloatRnd(rootseed) * irr);
        4: Primitive_ZStar(round(x * celw + celw / 2 + distribution *
            GetFloatRnd(rootseed) * celw),
            round(y * celh + celh / 2 + distribution * GetFloatRnd(rootseed) * celh),
            round(2 * celw * scale), round(2 * celh * scale), PI *
            GetFloatRnd(rootseed) * irr, PI * GetFloatRnd(rootseed) * irr);
        5: Primitive_ZSinSquare(
            round(x * celw + celw / 2 + distribution * GetFloatRnd(rootseed) * celw),
            round(y * celh + celh / 2 + distribution * GetFloatRnd(rootseed) * celh),
            round(1.3 * celw * scale), round(1.3 * celh * scale),
            PI * GetFloatRnd(rootseed) * irr,
            PI * GetFloatRnd(rootseed) * irr);
      end;
    end;
  end;
end;

 {******************************************************************************}
 // WoodRings
procedure TTextureGenerator.Generate_WoodRings(w, h, ax, ay: integer;density: single; iterations: integer; rootseed: cardinal);
var
  x, y, z, adr, bx, by: integer;
  p: TRGBAColor;
  tx, ty, px, py, a, b, c: single;
  mbx, mby: single;

  procedure RandomBooble(Iterationsx, Iterationsy: integer);
  var
    i, j:      integer;
    rrx, rry, r: single;
    adr, adrr: cardinal;
  begin
    {$R-}
    {$Q-}
    bx  := round(Width * (GetFloatRnd(rootseed) + 1) / 2);
    by  := round(Height * (GetFloatRnd(rootseed) + 1) / 2);

  //  if Iterationsx > 10 then Iterationsx:=10;
   // if Iterationsy > 10 then Iterationsy:=10;

    rrx := Iterationsx * Iterationsx;
    if rrx = 0 then rrx:=1;

    rry := Iterationsy * Iterationsy;
    if rry = 0 then rry:=1;

    for j := -Iterationsy to Iterationsy do
    begin
      adr := (cardinal(j + by) mod Height) * Width;
      for i := -Iterationsx to Iterationsx do
      begin
        r := sqrt(i * i / rrx + j * j / rry);
        if r < 1 then
        begin
          adrr := adr + (cardinal(i + bx) mod Width);
          rgba^[adrr].r := rgba^[adrr].r + Cos(0.5 * PI * r) * density;
        end;
      end;
    end;
    {$Q+}
    {$R+}
  end;

begin
  SetNewBitmap;
  for y := 0 to Height - 1 do
  begin
    for x := 0 to Width - 1 do
    begin
      rgba^[y * Width + x].r := 0;
      rgba^[y * Width + x].a := 1;
    end;
  end;

  for x := 0 to w - 1 do
    for y := 0 to h - 1 do
      for z := 0 to iterations - 1 do
        RandomBooble(ax * Width div w, ay * Height div h);

  for y := 0 to Width * Height - 1 do
  begin
    if rgba^[y].r > 1 then
      rgba^[y].r := frac(rgba^[y].r);
  end;
end;

 {******************************************************************************}
 // PerlinNoise
procedure TTextureGenerator.Generate_PerlinNoise(rootseed: cardinal);
var
  x, y: integer;
begin
  SetNewBitmap;

end;

 {******************************************************************************}
 // Clouds
procedure TTextureGenerator.Generate_Clouds(w, h: integer;
  filter, iterations: integer; intensity, distortion, CloudCover, CloudSharpness: single;
  rootseed: cardinal);

var
  i: integer;
  c: single;
begin
  SetNewBitmap;
  if CloudSharpness <= 0 then
    CloudSharpness := 0.0000000001;
  Generate_Noise(w, h, filter, iterations, intensity, distortion, rootseed);
  for i := 0 to Width * Height - 1 do
  begin
    c := rgba^[i].r - CloudCover;
    if c < 0 then
      c := 0;
    rgba^[i].r := (1 - power(CloudSharpness, c));
  end;
end;

{******************************************************************************}

{*******************************************************************************
                                   COLOR
*******************************************************************************}
// ChangeBCI
procedure TTextureGenerator.Color_ChangeBCI(b, c, i: single);
begin

end;

 {******************************************************************************}
 // ChangeHSB
procedure TTextureGenerator.Color_ChangeHSB(h, s, b: integer);
// h=(-360,360) s,b=(-100,100)
var
  fs, fb, _h, _s, _l: single;
  i: integer;
begin
  fs := s / 100;
  fb := b / 100;
  for i := 0 to Width * Height - 1 do
  begin
    rgba^[i].GetHUE(_h, _s, _l);
    _h := _h + h;
    if h < 0 then
      h := h + 360;
    if h > 360 then
      h := h - 360;
    _s  := _s + fs;
    if _s < 0 then
      _s := 0;
    if _s > 1 then
      _s := 1;
    _l   := _l + fb;
    if _l < 0 then
      _l := 0;
    if _l > 1 then
      _l := 1;
    rgba^[i].SetHUE(_h, _s, _l);
  end;
end;

 {******************************************************************************}
 // ColorGradient
procedure TTextureGenerator.Color_ColorGradient(gradient: TRGBAGradient);
var
  adr: integer;
begin
  for adr := 0 to Height * Width - 1 do
    rgba^[adr] := gradient.GetColor(rgba^[adr].r);
end;

 {******************************************************************************}
 // Colorize
procedure TTextureGenerator.Color_Colorize(color: TRGBAColor; mode, method: integer);
var
  adr, i, r, g, b: integer;
  gr:   TRGBAGradient;
  seed: cardinal;
begin
  if mode = 0 then
  begin
    r := color.Ir;
    g := color.Ig;
    b := color.Ib;
  end
  else
  begin
    seed := mode;
    repeat
      r := irandom(seed, 256);
      g := irandom(seed, 256);
      b := irandom(seed, 256);
    until ((r + g + b) > 550);
  end;
  gr := TRGBAGradient.Create;
  for i := 0 to 255 do
  begin
    gr.Add(i / 255, round(min(i * r / 127, 255)) / 255,
      round(min(i * g / 127, 255)) / 255,
      round(min(i * b / 127, 255)) / 255, 1);
  end;
  // Создаем палитру
  if method = 0 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      rgba^[adr]   := gr.GetColor(rgba^[adr].r);
      rgba^[adr].r := 1 - rgba^[adr].r;
      rgba^[adr].r := rgba^[adr].r * rgba^[adr].r;
      rgba^[adr].g := 1 - rgba^[adr].g;
      rgba^[adr].g := rgba^[adr].g * rgba^[adr].g;
      rgba^[adr].b := 1 - rgba^[adr].b;
      rgba^[adr].b := rgba^[adr].b * rgba^[adr].b;
    end;
  end
  else if method = 1 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      rgba^[adr]   := gr.GetColor(rgba^[adr].r);
      rgba^[adr].r := rgba^[adr].r;
      rgba^[adr].r := rgba^[adr].r * rgba^[adr].r;
      rgba^[adr].g := rgba^[adr].g;
      rgba^[adr].g := rgba^[adr].g * rgba^[adr].g;
      rgba^[adr].b := rgba^[adr].b;
      rgba^[adr].b := rgba^[adr].b * rgba^[adr].b;
    end;
  end
  else if method = 2 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      rgba^[adr]   := gr.GetColor(rgba^[adr].r);
      rgba^[adr].r := 1 - rgba^[adr].r;
      rgba^[adr].r := rgba^[adr].r * rgba^[adr].r * rgba^[adr].r;
      rgba^[adr].g := 1 - rgba^[adr].g;
      rgba^[adr].g := rgba^[adr].g * rgba^[adr].g * rgba^[adr].g;
      rgba^[adr].b := 1 - rgba^[adr].b;
      rgba^[adr].b := rgba^[adr].b * rgba^[adr].b * rgba^[adr].b;
    end;
  end
  else if method = 3 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      rgba^[adr]   := gr.GetColor(rgba^[adr].r);
      rgba^[adr].r := rgba^[adr].r;
      rgba^[adr].r := rgba^[adr].r * rgba^[adr].r * rgba^[adr].r;
      rgba^[adr].g := rgba^[adr].g;
      rgba^[adr].g := rgba^[adr].g * rgba^[adr].g * rgba^[adr].g;
      rgba^[adr].b := rgba^[adr].b;
      rgba^[adr].b := rgba^[adr].b * rgba^[adr].b * rgba^[adr].b;
    end;
  end
  else if method = 4 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      rgba^[adr]   := gr.GetColor(rgba^[adr].r);
      rgba^[adr].r := 1 - rgba^[adr].r;
      rgba^[adr].r := rgba^[adr].r * rgba^[adr].r * rgba^[adr].r * rgba^[adr].r;
      rgba^[adr].g := 1 - rgba^[adr].g;
      rgba^[adr].g := rgba^[adr].g * rgba^[adr].g * rgba^[adr].g * rgba^[adr].g;
      rgba^[adr].b := 1 - rgba^[adr].b;
      rgba^[adr].b := rgba^[adr].b * rgba^[adr].b * rgba^[adr].b * rgba^[adr].b;
    end;
  end
  else if method = 5 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      rgba^[adr]   := gr.GetColor(rgba^[adr].r);
      rgba^[adr].r := rgba^[adr].r;
      rgba^[adr].r := rgba^[adr].r * rgba^[adr].r * rgba^[adr].r * rgba^[adr].r;
      rgba^[adr].g := rgba^[adr].g;
      rgba^[adr].g := rgba^[adr].g * rgba^[adr].g * rgba^[adr].g * rgba^[adr].g;
      rgba^[adr].b := rgba^[adr].b;
      rgba^[adr].b := rgba^[adr].b * rgba^[adr].b * rgba^[adr].b * rgba^[adr].b;
    end;
  end
  else if method = 6 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      if rgba^[adr].r > 0.00001 then
        rgba^[adr].r := 0.1 / (rgba^[adr].r)
      else
        rgba^[adr].r := 1;
      rgba^[adr].g := 0;
      rgba^[adr].b := 0;
    end;
  end
  else if method = 7 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      rgba^[adr].r := sin(PI * rgba^[adr].r / 2);
      rgba^[adr].g := 0;
      rgba^[adr].b := 0;
    end;
  end
  else if method = 8 then
  begin
    for adr := 0 to Height * Width - 1 do
    begin
      rgba^[adr].r := 1 - sin(PI * rgba^[adr].r / 2);
      rgba^[adr].g := 0;
      rgba^[adr].b := 0;
    end;
  end;
  gr.Destroy;
end;

 {******************************************************************************}
 // ToneCurve
procedure TTextureGenerator.Color_ToneCurve;
begin

end;

{******************************************************************************}

{*******************************************************************************
                                   FILTER
*******************************************************************************}
// GaussianBlur
procedure TTextureGenerator.Filter_GaussianBlur(Iterations: single);
var
  x, y, z: integer;
  a, b, c, kw, tr, tg, tb, ta: single;
  px:    TRGBAColor;
  wsize: integer;
  adr, adrr: cardinal;
  w:     array [-100..100] of single;
  nrgba: PRGBAColorArray;

begin
  if Iterations <= 0 then
    Iterations := 1;
  // Вычисляем кривую Гаусса - на графике похожа на Сиську )
  b := 0;
  for x := -100 to 100 do
  begin
    a    := x / Iterations;
    w[x] := exp(-a * a / 2);
    b    := b + w[x];
  end;
  // Нормализуем коэффициенты гаусса
  wsize := 100;
  if b = 0 then
    b := 1;
  c   := 1 / (2 * 255); // k
  for x := -100 to 100 do
  begin
    w[x] := w[x] / b;
    if (x < 0) and (w[x] < c) then
      Dec(wsize);
  end;
  b := 0;
  for x := -wsize to wsize do
    b := b + w[x];
  if b = 0 then
    b := 1;
  for x := -wsize to wsize do
    w[x] := w[x] / b;

  nrgba := nil;
  ReAllocMem(nrgba, Width * Height * 4 * 4);
  // Размываем каждую строку
  for y := 0 to Height - 1 do
  begin
    adr := Width * y;
    for x := 0 to Width - 1 do
    begin
      tr := 0;
      tg := 0;
      tb := 0;
      ta := 0;
      for z := -wsize to wsize do
      begin
        kw   := w[z];
        adrr := adr + (cardinal(x - z) mod Width);
        tr   := tr + rgba^[adrr].r * kw;
        tg   := tg + rgba^[adrr].g * kw;
        tb   := tb + rgba^[adrr].b * kw;
        ta   := ta + rgba^[adrr].a * kw;
      end;
      nrgba^[adr + x].Eqv(tr, tg, tb, ta);
    end;
  end;
  // Размываем колонку
  for x := 0 to Height - 1 do
  begin
    for y := 0 to Width - 1 do
    begin
      tr := 0;
      tg := 0;
      tb := 0;
      ta := 0;
      for z := -wsize to wsize do
      begin
        kw   := w[z];
        adrr := (cardinal(y - z) mod Width) * Width + x;
        tr   := tr + nrgba^[adrr].r * kw;
        tg   := tg + nrgba^[adrr].g * kw;
        tb   := tb + nrgba^[adrr].b * kw;
        ta   := ta + nrgba^[adrr].a * kw;
      end;
      rgba^[Width * y + x].Eqv(tr, tg, tb, ta);
    end;
  end;
  FreeMem(nrgba);
end;

{******************************************************************************}

{*******************************************************************************
                                   TRANSFORM
*******************************************************************************}
// Rotate
procedure TTextureGenerator.Transform_Rotate(src: TTextureGenerator; angle: single);
var
  i, j, rx, ry: integer;
  x, y, sina, cosa, a, wd2, hd2: single;
begin
  if rgba = nil then
    SetNewBitmap;
  if (src = nil) or (src.rgba = nil) then
    exit;
  a    := angle * PI / 180 + PI / 2;
  sina := sin(a);
  cosa := cos(a);
  wd2  := Width / 2;
  hd2  := Height / 2;
  for j := 0 to Height - 1 do
  begin
    y := j - hd2;
    for i := 0 to Width - 1 do
    begin
      x  := i - wd2;
      rx := DWord(round(x * sina - y * cosa + wd2)) mod Width;
      ry := DWord(round(x * cosa + y * sina + hd2)) mod Height;
      rgba^[Width * j + i] := src.rgba^[Width * ry + rx];
    end;
  end;
end;

 {******************************************************************************}
 // Move
procedure TTextureGenerator.Transform_Move(src: TTextureGenerator; dx, dy: single);
var
  i, j, rx, ry: integer;
  x, y, sina, cosa, a, wd2, hd2: single;
begin
  if rgba = nil then
    SetNewBitmap;
  if (src = nil) or (src.rgba = nil) then
    exit;
  for j := 0 to Height - 1 do
  begin
    y := j + dy;
    for i := 0 to Width - 1 do
    begin
      x  := i + dx;
      rx := DWord(round(x)) mod Width;
      ry := DWord(round(y)) mod Height;
      rgba^[Width * j + i] := src.rgba^[Width * ry + rx];
    end;
  end;
end;

 {******************************************************************************}
 // Fractalize
procedure TTextureGenerator.Transform_Fractalize(src: TTextureGenerator;
  iterations, blend: integer);
var
  i, j, k, x, y: integer;
  n, mn: single;
  c, v:  TRGBAColor;
begin
  if rgba = nil then
    SetNewBitmap;
  if (src = nil) or (src.rgba = nil) then
    exit;
  if iterations < 0 then
    iterations := 0;
  if iterations > round(Log2(src.Width)) then
    iterations := round(Log2(src.Width));

  if blend = 0 then
  begin

    for j := 0 to Height - 1 do
    begin
      for i := 0 to Width - 1 do
      begin
        c := src.rgba^[Width * j + i];
        k := 2;
        while k <= iterations do
        begin
          y := (j * k) mod Width;
          x := (i * k) mod Height;
          c.Blend(src.rgba^[Width * y + x]);
          Inc(k);
        end;
        c.a := 1;
        rgba^[Width * j + i] := c;
      end;
    end;

  end
  else if blend = 1 then
  begin

    for j := 0 to Height - 1 do
    begin
      for i := 0 to Width - 1 do
      begin
        c := src.rgba^[Width * j + i];
        k := 2;
        while k <= iterations do
        begin
          y := (j * k) mod Width;
          x := (i * k) mod Height;
          c.Blend(src.rgba^[Width * y + x], 1 / (iterations + 1));
          Inc(k);
        end;
        c.a := 1;
        rgba^[Width * j + i] := c;
      end;
    end;

  end
  else
  begin

    for j := 0 to Height - 1 do
    begin
      for i := 0 to Width - 1 do
      begin
        c := src.rgba^[Width * j + i];
        k := 2;
        while k <= iterations do
        begin
          y := (j * k) mod Width;
          x := (i * k) mod Height;
          v := src.rgba^[Width * y + x];
          v.MulC(1 / (iterations + 1));
          c.Add(v);
          Inc(k);
        end;
        //        c.MulC(1/(iterations));
        c.a := 1;
        rgba^[Width * j + i] := c;
      end;
    end;

  end;
end;

 {******************************************************************************}
 // Twist
procedure TTextureGenerator.Transform_Twist(src: TTextureGenerator;
  amount, size, zoomin, zoomout, xpos, ypos: single);
var
  i, j: integer;
  x, y, nx, ny, angle, bb, zz, zza: single;
begin
  SetNewBitmap;
  bb := size;
  if bb < 0.000001 then
    bb := 0.00001;
  zza  := zoomout;
  for j := 0 to Height - 1 do
    for i := 0 to Width - 1 do
    begin
      x     := 2 * i / Width - 1 - xpos;
      y     := 2 * j / Height - 1 - ypos;
      angle := amount * exp(-(x * x + y * y) / (bb));
      zz    := 1 + zoomin * exp(-(x * x + y * y) / (bb));
      nx    := zz * (cos(angle) * x * zza + sin(angle) * y * zza) + xpos;
      ny    := zz * (-sin(angle) * x * zza + cos(angle) * y * zza) + ypos;
      rgba^[Width * j + i] := src.GetPixel(nx * 0.5 + 0.5, ny * 0.5 + 0.5);
    end;
end;

{******************************************************************************}
procedure TTextureGenerator.Transform_Disorder(one, two, alpha: TTextureGenerator;
  method: integer);
begin

end;

 {******************************************************************************}
 // Distort
procedure TTextureGenerator.Transform_Distort(src, dir, dist: TTextureGenerator;
  intensitydir, intensitydist: single; mode: integer);
var
  i, j: integer;
  x, y, fdir, fdist: single;
  c:    TRGBAColor;
begin
  SetNewBitmap;
  for j := 0 to Height - 1 do
    for i := 0 to Width - 1 do
    begin
      x     := i / Width;
      y     := j / Height;
      fdir  := intensitydir * dir.GetPixel(x, y).r * 2 * PI;
      fdist := intensitydist * dist.GetPixel(x, y).r;
      case Mode of
        0: rgba^[Width * j + i] :=
            src.GetPixel(x + fdist * sin(fdir), y + fdist * sin(fdir));
        1: rgba^[Width * j + i] :=
            src.GetPixel(x + fdist * sin(fdir), y + fdist * cos(fdir));
        2: rgba^[Width * j + i] :=
            src.GetPixel(x + fdist * cos(fdir), y + fdist * sin(fdir));
        3: rgba^[Width * j + i] :=
            src.GetPixel(x + fdist * cos(fdir), y + fdist * cos(fdir));
      end;
    end;
end;

 {******************************************************************************}
 // Waves
procedure TTextureGenerator.Transform_Waves(src: TTextureGenerator;
  method: integer; ax, bx, ay, by: single);
var
  i, j: integer;
  x, y: single;
  nrgba, trgba: PRGBAColorArray;
begin
  if rgba = nil then
    SetNewBitmap;
  if (src = nil) or (src.rgba = nil) then
    exit;

  if method = 0 then
  begin
    for j := 0 to Height - 1 do
      for i := 0 to Width - 1 do
      begin
        x := i / Width;
        y := j / Height;
        rgba^[Width * j + i] := src.GetPixel(x + ax * sin(y * 2 * PI * bx), y);
      end;
  end
  else if method = 1 then
  begin
    for j := 0 to Height - 1 do
      for i := 0 to Width - 1 do
      begin
        x := i / Width;
        y := j / Height;
        rgba^[Width * j + i] := src.GetPixel(x, y + ay * sin(x * 2 * PI * by));
      end;
  end
  else if method = 2 then
  begin
    for j := 0 to Height - 1 do
      for i := 0 to Width - 1 do
      begin
        x := i / Width;
        y := j / Height;
        rgba^[Width * j + i] :=
          src.GetPixel(x + ax * sin(y * 2 * PI * bx), y + ay * sin(x * 2 * PI * by));
      end;
  end
  else if method = 3 then
  begin
    nrgba := nil;
    ReAllocMem(nrgba, Width * Height * 4 * 4);
    for j := 0 to Height - 1 do
      for i := 0 to Width - 1 do
      begin
        x := i / Width;
        y := j / Height;
        nrgba^[Width * j + i] := src.GetPixel(x + ax * sin(y * 2 * PI * bx), y);
      end;
    trgba    := src.rgba;
    src.rgba := nrgba;
    for j := 0 to Height - 1 do
      for i := 0 to Width - 1 do
      begin
        x := i / Width;
        y := j / Height;
        rgba^[Width * j + i] := src.GetPixel(x, y + ay * sin(x * 2 * PI * by));
      end;
    src.rgba := trgba;
    Freemem(nrgba);
  end;
end;

{******************************************************************************}

{*******************************************************************************
                                    COMBINE
*******************************************************************************}
// AlphaMask
procedure TTextureGenerator.Combine_AlphaMask(one, two, alpha: TTextureGenerator;
  inversed: integer);
var
  adr: integer;
  alph, oneminusalph: single;
begin
  SetNewBitmap;
  for adr := 0 to Width * Height - 1 do
  begin
    if inversed = 1 then
    begin
      oneminusalph := alpha.rgba^[adr].r;
      alph := 1 - oneminusalph;
    end
    else
    begin
      alph := alpha.rgba^[adr].r;
      oneminusalph := 1 - alph;
    end;
    rgba^[adr].r := one.rgba^[adr].r * oneminusalph + two.rgba^[adr].r * alph;
    rgba^[adr].g := one.rgba^[adr].g * oneminusalph + two.rgba^[adr].g * alph;
    rgba^[adr].b := one.rgba^[adr].b * oneminusalph + two.rgba^[adr].b * alph;
    rgba^[adr].a := 1;
  end;
end;

 {******************************************************************************}
 // Blend
procedure TTextureGenerator.Combine_Blend(one, two: TTextureGenerator;
  method, mode: integer);
var
  adr: integer;
  alph, oneminusalph, a1, a2, b1, b2, c1, c2: single;
begin
  SetNewBitmap;
  if method = 0 then
  begin
    // A + B
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := one.rgba^[adr].r + two.rgba^[adr].r;
      rgba^[adr].g := one.rgba^[adr].g + two.rgba^[adr].g;
      rgba^[adr].b := one.rgba^[adr].b + two.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := one.rgba^[adr].a + two.rgba^[adr].a;
    end;
  end
  else if method = 1 then
  begin
    // A - B
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := one.rgba^[adr].r - two.rgba^[adr].r;
      rgba^[adr].g := one.rgba^[adr].g - two.rgba^[adr].g;
      rgba^[adr].b := one.rgba^[adr].b - two.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := one.rgba^[adr].a - two.rgba^[adr].a;
    end;
  end
  else if method = 2 then
  begin
    // A * B
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := one.rgba^[adr].r * two.rgba^[adr].r;
      rgba^[adr].g := one.rgba^[adr].g * two.rgba^[adr].g;
      rgba^[adr].b := one.rgba^[adr].b * two.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := one.rgba^[adr].a * two.rgba^[adr].a;
    end;
  end
  else if method = 3 then
  begin
    // A xor B
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].SetDWABGR(one.rgba^[adr].GetDWABGR xor two.rgba^[adr].GetDWABGR);
      if mode = 0 then
        rgba^[adr].a := 1;
    end;
  end
  else if method = 4 then
  begin
    // A or B
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].SetDWABGR(one.rgba^[adr].GetDWABGR or two.rgba^[adr].GetDWABGR);
      if mode = 0 then
        rgba^[adr].a := 1;
    end;
  end
  else if method = 5 then
  begin
    // A and B
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].SetDWABGR(one.rgba^[adr].GetDWABGR and two.rgba^[adr].GetDWABGR);
      if mode = 0 then
        rgba^[adr].a := 1;
    end;
  end
  else if method = 6 then
  begin
    // A.hue + B.hue
    for adr := 0 to Width * Height - 1 do
    begin
      one.rgba^[adr].GetHUE(a1, b1, c1);
      two.rgba^[adr].GetHUE(a2, b2, c2);
      rgba^[adr].SetHUE(a1 + a2, b1 + b2, c1 + c2);
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := one.rgba^[adr].a + two.rgba^[adr].a;
    end;
  end
  else if method = 7 then
  begin
    // A.hue - B.hue
    for adr := 0 to Width * Height - 1 do
    begin
      one.rgba^[adr].GetHUE(a1, b1, c1);
      two.rgba^[adr].GetHUE(a2, b2, c2);
      rgba^[adr].SetHUE(a1 - a2, b1 - b2, c1 - c2);
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := one.rgba^[adr].a + two.rgba^[adr].a;
    end;
  end
  else if method = 8 then
  begin
    // A.hue * B.hue
    for adr := 0 to Width * Height - 1 do
    begin
      one.rgba^[adr].GetHUE(a1, b1, c1);
      two.rgba^[adr].GetHUE(a2, b2, c2);
      rgba^[adr].SetHUE(a1 * a2, b1 * b2, c1 * c2);
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := one.rgba^[adr].a + two.rgba^[adr].a;
    end;
  end
  else if method = 9 then
  begin
    // A + B.brightness
    for adr := 0 to Width * Height - 1 do
    begin
      one.rgba^[adr].GetHUE(a1, b1, c1);
      two.rgba^[adr].GetHUE(a2, b2, c2);
      rgba^[adr].SetHUE(a1, b1 + b2, c1);
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := one.rgba^[adr].a + two.rgba^[adr].a;
    end;
  end
  else if method = 10 then
  begin
    // A + B.rgb*B.a
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := one.rgba^[adr].r + two.rgba^[adr].r * two.rgba^[adr].a;
      rgba^[adr].g := one.rgba^[adr].g + two.rgba^[adr].g * two.rgba^[adr].a;
      rgba^[adr].b := one.rgba^[adr].b + two.rgba^[adr].b * two.rgba^[adr].a;
      if mode = 0 then
        rgba^[adr].a := 1;
    end;
  end
  else if method = 11 then
  begin
    // A*(1-B.a) + B.rgb*B.a
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := one.rgba^[adr].r * (1 - two.rgba^[adr].a) +
        two.rgba^  [adr].r * two.rgba^[adr].a;
      rgba^[adr].g := one.rgba^[adr].g * (1 - two.rgba^[adr].a) +
        two.rgba^  [adr].g * two.rgba^[adr].a;
      rgba^[adr].b := one.rgba^[adr].b * (1 - two.rgba^[adr].a) +
        two.rgba^  [adr].b * two.rgba^[adr].a;
      if mode = 0 then
        rgba^[adr].a := 1;
    end;
  end
  else if method = 12 then
  begin
    // A - B
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := one.rgba^[adr].r - two.rgba^[adr].r;
      rgba^[adr].g := one.rgba^[adr].g - two.rgba^[adr].g;
      rgba^[adr].b := one.rgba^[adr].b - two.rgba^[adr].b;
      while rgba^[adr].r < -0.001 do
        rgba^[adr].r := rgba^[adr].r + 1;
      while rgba^[adr].g < -0.001 do
        rgba^[adr].g := rgba^[adr].g + 1;
      while rgba^[adr].b < -0.001 do
        rgba^[adr].b := rgba^[adr].b + 1;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := one.rgba^[adr].a - two.rgba^[adr].a;
    end;
  end
  else if method = 13 then
  begin
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := (one.rgba^[adr].r * 1.5 + 0.5) * two.rgba^[adr].r;
      rgba^[adr].g := (one.rgba^[adr].g * 1.5 + 0.5) * two.rgba^[adr].g;
      rgba^[adr].b := (one.rgba^[adr].b * 1.5 + 0.5) * two.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := (one.rgba^[adr].a * 1.5 + 0.5) * two.rgba^[adr].a;
    end;
  end
  else if method = 14 then
  begin
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := (one.rgba^[adr].r * 2 + 0.5) * two.rgba^[adr].r;
      rgba^[adr].g := (one.rgba^[adr].g * 2 + 0.5) * two.rgba^[adr].g;
      rgba^[adr].b := (one.rgba^[adr].b * 2 + 0.5) * two.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := (one.rgba^[adr].a * 1.5 + 0.5) * two.rgba^[adr].a;
    end;
  end
  else if method = 15 then
  begin
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := (one.rgba^[adr].r + 0.5) * two.rgba^[adr].r;
      rgba^[adr].g := (one.rgba^[adr].g + 0.5) * two.rgba^[adr].g;
      rgba^[adr].b := (one.rgba^[adr].b + 0.5) * two.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := (one.rgba^[adr].a * 1.5 + 0.5) * two.rgba^[adr].a;
    end;
  end
  else if method = 16 then
  begin
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := (two.rgba^[adr].r * 1.5 + 0.5) * one.rgba^[adr].r;
      rgba^[adr].g := (two.rgba^[adr].g * 1.5 + 0.5) * one.rgba^[adr].g;
      rgba^[adr].b := (two.rgba^[adr].b * 1.5 + 0.5) * one.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := (two.rgba^[adr].a * 1.5 + 0.5) * one.rgba^[adr].a;
    end;
  end
  else if method = 17 then
  begin
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := (two.rgba^[adr].r * 2 + 0.5) * one.rgba^[adr].r;
      rgba^[adr].g := (two.rgba^[adr].g * 2 + 0.5) * one.rgba^[adr].g;
      rgba^[adr].b := (two.rgba^[adr].b * 2 + 0.5) * one.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := (two.rgba^[adr].a * 1.5 + 0.5) * one.rgba^[adr].a;
    end;
  end
  else if method = 18 then
  begin
    for adr := 0 to Width * Height - 1 do
    begin
      rgba^[adr].r := (two.rgba^[adr].r + 0.5) * one.rgba^[adr].r;
      rgba^[adr].g := (two.rgba^[adr].g + 0.5) * one.rgba^[adr].g;
      rgba^[adr].b := (two.rgba^[adr].b + 0.5) * one.rgba^[adr].b;
      if mode = 0 then
        rgba^[adr].a := 1
      else
        rgba^[adr].a := (two.rgba^[adr].a * 1.5 + 0.5) * one.rgba^[adr].a;
    end;
  end;
  for adr := 0 to Width * Height - 1 do
  begin
    if rgba^[adr].r > 1 then
      rgba^[adr].r := 1
    else if rgba^[adr].r < 0 then
      rgba^[adr].r := 0;
    if rgba^[adr].g > 1 then
      rgba^[adr].g := 1
    else if rgba^[adr].g < 0 then
      rgba^[adr].g := 0;
    if rgba^[adr].b > 1 then
      rgba^[adr].b := 1
    else if rgba^[adr].b < 0 then
      rgba^[adr].b := 0;
    if rgba^[adr].a > 1 then
      rgba^[adr].a := 1
    else if rgba^[adr].a < 0 then
      rgba^[adr].a := 0;
  end;
end;

{******************************************************************************}

{*******************************************************************************
                                    ALPHA
*******************************************************************************}
// MakeAlpha
procedure TTextureGenerator.Transparency_MakeAlpha(alphasource: TTextureGenerator;
  inverse: integer);
var
  adr: integer;
begin
  if inverse = 0 then
    for adr := 0 to Width * Height - 1 do
      rgba^[adr].a := alphasource.rgba^[adr].r
  else
    for adr := 0 to Width * Height - 1 do
      rgba^[adr].a := 1 - alphasource.rgba^[adr].r;
end;

 {******************************************************************************}
 // FillAlpha
procedure TTextureGenerator.Transparency_FillAlpha(_alpha: single);
var
  adr: integer;
begin
  if _alpha < 0 then
    _alpha := 0
  else if _alpha > 1 then
    _alpha := 1;
  for adr := 0 to Width * Height - 1 do
    rgba^[adr].a := _alpha;
end;

 {******************************************************************************}
 // AlphaFromColor
procedure TTextureGenerator.Transparency_AlphaFromColor(method: integer;
  kc, kr, kg, kb: single);
var
  adr: integer;
  a:   single;
begin
  for adr := 0 to Width * Height - 1 do
  begin
    a := kc + kr * rgba^[adr].r + kg * rgba^[adr].g + kb * rgba^[adr].b;
    if a < 0 then
      a := 0
    else if a > 1 then
      a := 1;
    rgba^[adr].a := a;
  end;
end;

{******************************************************************************}

{*******************************************************************************
                                    Lighting
*******************************************************************************}
 // Lighting
 // http://dtimofeev.blogspot.com/2009/06/calculation-deep-normal-map.html
procedure TTextureGenerator.Lighting_Lighting(src: TTextureGenerator; lx,ly,lz:Single;Relief:Single;NormalMapSmooth,Invert:Integer);
var
  x, y, z, nx, ny, sx, sy, adr: integer;
  fx, fy, fnx, fny, fsx, fsy: single;
  c00, c10, c01, c20, c02,c22,c11,c21,c12: TRGBAColor;
  h0,h1,h2,h3,h4,h5,h6,h7,h8,l: single;
  normal,v: TVector;
  vecarray:PVectorArray;
begin
  SetNewBitmap;
  if not src.IsLoaded or (src.rgba = nil) then  exit;

  if NormalMapSmooth<0 then NormalMapSmooth:=0;
  if NormalMapSmooth>50 then NormalMapSmooth:=50;

  vecarray:=nil;
  ReAllocMem(vecarray,Width * Height * sizeof(TVector));

  // Расчет normalmap - именно такой который используется в шейдерах
  for y := 0 to Height - 1 do begin
    ny := (y + 1) mod Height;
    sy := (y - 1);
    if sy < 0 then sy := sy + Height;
    fy   := y / Height;
    fny  := ny / Height;
    fsy  := sy / Height;
    for x := 0 to Width - 1 do begin
      adr := y * Width + x;
      nx  := (x + 1) mod Width;
      sx  := (x - 1);
      if sx < 0 then
        sx := sx + Width;
      fx   := x / Width;
      fnx  := nx / Width;
      fsx  := sx / Width;

      c00 := src.GetPixel(fx, fy);
      c10 := src.GetPixel(fnx, fy);
      c01 := src.GetPixel(fx, fny);
      c20 := src.GetPixel(fsx, fy);
      c02 := src.GetPixel(fx, fsy);
      c22 := src.GetPixel(fsx, fsy);
      c12 := src.GetPixel(fnx, fsy);
      c21 := src.GetPixel(fsx, fny);
      c11 := src.GetPixel(fnx, fny);

      h0 := c00.GetLighting-c22.GetLighting;
      h1 := c00.GetLighting-c02.GetLighting;
      h2 := c00.GetLighting-c12.GetLighting;
      h3 := c00.GetLighting-c20.GetLighting;
      h4 := c00.GetLighting-c10.GetLighting;
      h5 := c00.GetLighting-c21.GetLighting;
      h6 := c00.GetLighting-c01.GetLighting;
      h7 := c00.GetLighting-c11.GetLighting;

      if Invert=0 then begin
        h0:=-h0;
        h1:=-h1;
        h2:=-h2;
        h3:=-h3;
        h4:=-h4;
        h5:=-h5;
        h6:=-h6;
        h7:=-h7;
      end;

      normal.Eqv(0, 0, 0);
      normal.Add(gV(-2*h0,2*h0,Relief*(1-h0)));
      normal.Add(gV(0,2*h1,Relief*(1-h1)));
      normal.Add(gV(2*h2,2*h2,Relief*(1-h2)));
      normal.Add(gV(-2*h3,0,Relief*(1-h3)));
      normal.Add(gV(2*h4,0,Relief*(1-h4)));
      normal.Add(gV(-2*h5,-2*h5,Relief*(1-h5)));
      normal.Add(gV(0,-2*h6,Relief*(1-h6)));
      normal.Add(gV(2*h7,-2*h7,Relief*(1-h7)));

      vecarray^[adr]:=normal.GetNormalized;
      rgba^[adr].r := vecarray^[adr].x;
      rgba^[adr].g := vecarray^[adr].y;
      rgba^[adr].b := vecarray^[adr].z;
    end;
  end;
  // Сглаживание нормалей
  for z:=0 to NormalMapSmooth do begin
    for y := 0 to Height - 1 do begin
      ny := (y + 1); if ny >=Height then ny := ny - Height;
      sy := (y - 1); if sy < 0 then sy := sy + Height;
      for x := 0 to Width - 1 do begin
        nx := (x + 1); if nx >=Height then nx := nx - Height;
        sx := (x - 1); if sx < 0 then sx := sx + Height;
        adr := y * Width + x;
        v:=vecarray^[adr];
        v.Add(vecarray^[Width*ny+x]);
        v.Add(vecarray^[Width*sy+x]);
        v.Add(vecarray^[Width*y+nx]);
        v.Add(vecarray^[Width*y+sx]);
        v.Add(vecarray^[Width*ny+sx]);
        v.Add(vecarray^[Width*sy+nx]);
        v.Add(vecarray^[Width*sy+sx]);
        v.Add(vecarray^[Width*ny+nx]);
        vecarray^[adr]:=v.GetNormalized;
      end;
    end;
  end;
  // Наложение света
  v:=gV(lx,ly,lz).GetNormalized;
  for y := 0 to Height - 1 do begin
    for x := 0 to Width - 1 do begin
      adr := y * Width + x;
      l:=DotVector(vecarray^[adr].AddV(gV(rgba^[adr].r,rgba^[adr].g,rgba^[adr].b)).GetNormalized,v);
      rgba^[adr].r := src.rgba^[adr].r*l;
      rgba^[adr].g := src.rgba^[adr].g*l;
      rgba^[adr].b := src.rgba^[adr].b*l;
      rgba^[adr].a := 1;
    end;

  end;
  Freemem(vecarray);
end;

{******************************************************************************}
procedure TTextureGenerator.Lighting_ReliefLighting(src,rel: TTextureGenerator; lx,ly,lz:Single;Relief:Single;NormalMapSmooth,Invert:Integer);
var
  x, y, z, nx, ny, sx, sy, adr: integer;
  fx, fy, fnx, fny, fsx, fsy: single;
  c00, c10, c01, c20, c02,c22,c11,c21,c12: TRGBAColor;
  h0,h1,h2,h3,h4,h5,h6,h7,h8,l: single;
  normal,v: TVector;
  vecarray:PVectorArray;
begin
  SetNewBitmap;
  if not src.IsLoaded or (src.rgba = nil) then  exit;

  if NormalMapSmooth<0 then NormalMapSmooth:=0;
  if NormalMapSmooth>50 then NormalMapSmooth:=50;

  vecarray:=nil;
  ReAllocMem(vecarray,Width * Height * sizeof(TVector));

  // Расчет normalmap - именно такой который используется в шейдерах
  for y := 0 to Height - 1 do begin
    ny := (y + 1) mod Height;
    sy := (y - 1);
    if sy < 0 then sy := sy + Height;
    fy   := y / Height;
    fny  := ny / Height;
    fsy  := sy / Height;
    for x := 0 to Width - 1 do begin
      adr := y * Width + x;
      nx  := (x + 1) mod Width;
      sx  := (x - 1);
      if sx < 0 then
        sx := sx + Width;
      fx   := x / Width;
      fnx  := nx / Width;
      fsx  := sx / Width;

      c00 := rel.GetPixel(fx, fy);
      c10 := rel.GetPixel(fnx, fy);
      c01 := rel.GetPixel(fx, fny);
      c20 := rel.GetPixel(fsx, fy);
      c02 := rel.GetPixel(fx, fsy);
      c22 := rel.GetPixel(fsx, fsy);
      c12 := rel.GetPixel(fnx, fsy);
      c21 := rel.GetPixel(fsx, fny);
      c11 := rel.GetPixel(fnx, fny);

      h0 := c00.GetLighting-c22.GetLighting;
      h1 := c00.GetLighting-c02.GetLighting;
      h2 := c00.GetLighting-c12.GetLighting;
      h3 := c00.GetLighting-c20.GetLighting;
      h4 := c00.GetLighting-c10.GetLighting;
      h5 := c00.GetLighting-c21.GetLighting;
      h6 := c00.GetLighting-c01.GetLighting;
      h7 := c00.GetLighting-c11.GetLighting;

      if Invert=0 then begin
        h0:=-h0;
        h1:=-h1;
        h2:=-h2;
        h3:=-h3;
        h4:=-h4;
        h5:=-h5;
        h6:=-h6;
        h7:=-h7;
      end;

      normal.Eqv(0, 0, 0);
      normal.Add(gV(-2*h0,2*h0,Relief*(1-h0)));
      normal.Add(gV(0,2*h1,Relief*(1-h1)));
      normal.Add(gV(2*h2,2*h2,Relief*(1-h2)));
      normal.Add(gV(-2*h3,0,Relief*(1-h3)));
      normal.Add(gV(2*h4,0,Relief*(1-h4)));
      normal.Add(gV(-2*h5,-2*h5,Relief*(1-h5)));
      normal.Add(gV(0,-2*h6,Relief*(1-h6)));
      normal.Add(gV(2*h7,-2*h7,Relief*(1-h7)));

      vecarray^[adr]:=normal.GetNormalized;
      rgba^[adr].r := vecarray^[adr].x;
      rgba^[adr].g := vecarray^[adr].y;
      rgba^[adr].b := vecarray^[adr].z;
    end;
  end;
  // Сглаживание нормалей
  for z:=0 to NormalMapSmooth do begin
    for y := 0 to Height - 1 do begin
      ny := (y + 1); if ny >=Height then ny := ny - Height;
      sy := (y - 1); if sy < 0 then sy := sy + Height;
      for x := 0 to Width - 1 do begin
        nx := (x + 1); if nx >=Height then nx := nx - Height;
        sx := (x - 1); if sx < 0 then sx := sx + Height;
        adr := y * Width + x;
        v:=vecarray^[adr];
        v.Add(vecarray^[Width*ny+x]);
        v.Add(vecarray^[Width*sy+x]);
        v.Add(vecarray^[Width*y+nx]);
        v.Add(vecarray^[Width*y+sx]);
        v.Add(vecarray^[Width*ny+sx]);
        v.Add(vecarray^[Width*sy+nx]);
        v.Add(vecarray^[Width*sy+sx]);
        v.Add(vecarray^[Width*ny+nx]);
        vecarray^[adr]:=v.GetNormalized;
      end;
    end;
  end;
  // Наложение света
  v:=gV(lx,ly,lz).GetNormalized;
  for y := 0 to Height - 1 do begin
    for x := 0 to Width - 1 do begin
      adr := y * Width + x;
      l:=DotVector(vecarray^[adr].AddV(gV(rgba^[adr].r,rgba^[adr].g,rgba^[adr].b)).GetNormalized,v);
      rgba^[adr].r := src.rgba^[adr].r*l;
      rgba^[adr].g := src.rgba^[adr].g*l;
      rgba^[adr].b := src.rgba^[adr].b*l;
      rgba^[adr].a := 1;
    end;

  end;
  Freemem(vecarray);
end;

{******************************************************************************}
procedure TTextureGenerator.Lighting_NormalMap(src: TTextureGenerator;Relief:Single;NormalMapSmooth,Invert:Integer);
var
  x, y, z, nx, ny, sx, sy, adr: integer;
  fx, fy, fnx, fny, fsx, fsy: single;
  c00, c10, c01, c20, c02,c22,c11,c21,c12: TRGBAColor;
  h0,h1,h2,h3,h4,h5,h6,h7,h8,l: single;
  normal,v: TVector;
  vecarray:PVectorArray;
begin
  SetNewBitmap;
  if not src.IsLoaded or (src.rgba = nil) then  exit;

  if NormalMapSmooth<0 then NormalMapSmooth:=0;
  if NormalMapSmooth>50 then NormalMapSmooth:=50;

  vecarray:=nil;
  ReAllocMem(vecarray,Width * Height * sizeof(TVector));

  // Расчет normalmap - именно такой который используется в шейдерах
  for y := 0 to Height - 1 do begin
    ny := (y + 1) mod Height;
    sy := (y - 1);
    if sy < 0 then sy := sy + Height;
    fy   := y / Height;
    fny  := ny / Height;
    fsy  := sy / Height;
    for x := 0 to Width - 1 do begin
      adr := y * Width + x;
      nx  := (x + 1) mod Width;
      sx  := (x - 1);
      if sx < 0 then
        sx := sx + Width;
      fx   := x / Width;
      fnx  := nx / Width;
      fsx  := sx / Width;

      c00 := src.GetPixel(fx, fy);
      c10 := src.GetPixel(fnx, fy);
      c01 := src.GetPixel(fx, fny);
      c20 := src.GetPixel(fsx, fy);
      c02 := src.GetPixel(fx, fsy);
      c22 := src.GetPixel(fsx, fsy);
      c12 := src.GetPixel(fnx, fsy);
      c21 := src.GetPixel(fsx, fny);
      c11 := src.GetPixel(fnx, fny);

      h0 := c00.GetLighting-c22.GetLighting;
      h1 := c00.GetLighting-c02.GetLighting;
      h2 := c00.GetLighting-c12.GetLighting;
      h3 := c00.GetLighting-c20.GetLighting;
      h4 := c00.GetLighting-c10.GetLighting;
      h5 := c00.GetLighting-c21.GetLighting;
      h6 := c00.GetLighting-c01.GetLighting;
      h7 := c00.GetLighting-c11.GetLighting;

      if Invert=0 then begin
        h0:=-h0;
        h1:=-h1;
        h2:=-h2;
        h3:=-h3;
        h4:=-h4;
        h5:=-h5;
        h6:=-h6;
        h7:=-h7;
      end;

      normal.Eqv(0, 0, 0);
      normal.Add(gV(-2*h0,2*h0,Relief*(1-h0)));
      normal.Add(gV(0,2*h1,Relief*(1-h1)));
      normal.Add(gV(2*h2,2*h2,Relief*(1-h2)));
      normal.Add(gV(-2*h3,0,Relief*(1-h3)));
      normal.Add(gV(2*h4,0,Relief*(1-h4)));
      normal.Add(gV(-2*h5,-2*h5,Relief*(1-h5)));
      normal.Add(gV(0,-2*h6,Relief*(1-h6)));
      normal.Add(gV(2*h7,-2*h7,Relief*(1-h7)));

      vecarray^[adr]:=normal.GetNormalized;
      rgba^[adr].r := vecarray^[adr].x;
      rgba^[adr].g := vecarray^[adr].y;
      rgba^[adr].b := vecarray^[adr].z;
    end;
  end;
  // Сглаживание нормалей
  for z:=0 to NormalMapSmooth do begin
    for y := 0 to Height - 1 do begin
      ny := (y + 1); if ny >=Height then ny := ny - Height;
      sy := (y - 1); if sy < 0 then sy := sy + Height;
      for x := 0 to Width - 1 do begin
        nx := (x + 1); if nx >=Height then nx := nx - Height;
        sx := (x - 1); if sx < 0 then sx := sx + Height;
        adr := y * Width + x;
        v:=vecarray^[adr];
        v.Add(vecarray^[Width*ny+x]);
        v.Add(vecarray^[Width*sy+x]);
        v.Add(vecarray^[Width*y+nx]);
        v.Add(vecarray^[Width*y+sx]);
        v.Add(vecarray^[Width*ny+sx]);
        v.Add(vecarray^[Width*sy+nx]);
        v.Add(vecarray^[Width*sy+sx]);
        v.Add(vecarray^[Width*ny+nx]);
        vecarray^[adr]:=v.GetNormalized;
      end;
    end;
  end;
  // Наложение света
  for y := 0 to Height - 1 do begin
    for x := 0 to Width - 1 do begin
      adr := y * Width + x;
      v:=vecarray^[adr].AddV(gV(rgba^[adr].r,rgba^[adr].g,rgba^[adr].b)).GetNormalized;
      rgba^[adr].r := v.x*0.5+0.5;
      rgba^[adr].g := v.y*0.5+0.5;
      rgba^[adr].b := v.z*0.5+0.5;
      rgba^[adr].a := 1;
    end;
  end;
  Freemem(vecarray);
end;
{******************************************************************************}

{******************************************************************************}

{*******************************************************************************
                                    Project
*******************************************************************************}
procedure TTextureGenerator.Project_EnvironmentMapping(src: TTextureGenerator;
  plane, mode: integer);

var
  i, j:  integer;
  xt, yt, zt, uu, vv: single;
  v, vr: TVector;

  function applyvector(tv: TVector): TVector;
  begin
    if mode = 0 then
    begin  // SPHERE
           //      tv.y:=tv.y;
      tv.Normalize;
      uu := (arctan2(tv.z, tv.x) / PI + 1) * 0.5;
      vv := arcsin(tv.y) / PI + 0.5;
      rgba^[Width * j + i] := src.GetPixel(uu, vv);
    end
    else if mode = 1 then
    begin // GEO2
      tv.y := tv.y * 2;
      tv.Normalize;
      uu := (arctan2(tv.z, tv.x) / PI + 1) * 0.5;
      vv := arcsin(tv.y) / PI + 0.5;
      rgba^[Width * j + i] := src.GetPixel(uu, vv);
    end
    else if mode = 2 then
    begin // GEO4
      tv.y := tv.y * 4;
      tv.Normalize;
      uu := (arctan2(tv.z, tv.x) / PI + 1) * 0.5;
      vv := arcsin(tv.y) / PI + 0.5;
      rgba^[Width * j + i] := src.GetPixel(uu, vv);
    end
    else if mode = 3 then
    begin // GEOSIN
      tv.y := sin(tv.y * PI * 0.5);
      tv.Normalize;
      uu := (arctan2(tv.z, tv.x) / PI + 1) * 0.5;
      vv := arcsin(tv.y) / PI + 0.5;
      rgba^[Width * j + i] := src.GetPixel(uu, vv);
    end
    else if mode = 4 then
    begin
      uu := tv.z * tv.y * 6 + 0.5;
      vv := tv.x * tv.y * 6 + 0.5;
      rgba^[Width * j + i] := src.GetPixel(uu, vv);

    end;
  end;

begin
  SetNewBitmap;
  if plane = 0 then
  begin // left
    vr.z := 0.5;
    for j := 0 to Height - 1 do
    begin
      vr.y := (j - Height div 2) / Height;
      for i := 0 to Width - 1 do
      begin
        vr.x := (i - Width div 2) / Width;
        applyvector(gV(vr.z, vr.y, -vr.x));
      end;
    end;
  end
  else if plane = 1 then
  begin // right
    vr.z := -0.5;
    for j := 0 to Height - 1 do
    begin
      vr.y := (j - Height div 2) / Height;
      for i := 0 to Width - 1 do
      begin
        vr.x := (i - Width div 2) / Width;
        applyvector(gV(vr.z, vr.y, vr.x));
      end;
    end;
  end
  else if plane = 2 then
  begin // up
    vr.z := 0.5;
    for j := 0 to Height - 1 do
    begin
      vr.y := (j - Height div 2) / Height;
      for i := 0 to Width - 1 do
      begin
        vr.x := (i - Width div 2) / Width;
        applyvector(gV(-vr.x, -0.5, -vr.y));
      end;
    end;
  end
  else if plane = 3 then
  begin // down
    vr.z := 0.5;
    for j := 0 to Height - 1 do
    begin
      vr.y := (j - Height div 2) / Height;
      for i := 0 to Width - 1 do
      begin
        vr.x := (i - Width div 2) / Width;
        applyvector(gV(-vr.x, 0.5, vr.y));
      end;
    end;
  end
  else if plane = 4 then
  begin // front
    vr.z := 0.5;
    for j := 0 to Height - 1 do
    begin
      vr.y := (j - Height div 2) / Height;
      for i := 0 to Width - 1 do
      begin
        vr.x := (i - Width div 2) / Width;
        applyvector(gV(vr.x, vr.y, vr.z));
      end;
    end;
  end
  else if plane = 5 then
  begin // back
    vr.z := -0.5;
    for j := 0 to Height - 1 do
    begin
      vr.y := (j - Height div 2) / Height;
      for i := 0 to Width - 1 do
      begin
        vr.x := (i - Width div 2) / Width;
        applyvector(gV(-vr.x, vr.y, vr.z));
      end;
    end;
  end;
end;
{******************************************************************************}

{******************************************************************************}
procedure TTextureGenerator.Cache(_IsAlpha: boolean);
var
  i, j, k: integer;
  p:     PByteArray;
  cc:    TRGBAColor;
  c:     DWord;
  ma, h: single;
begin
  if not IsLoaded then exit;
  if IsCached then UnCache;
  if rbm <> nil then rbm.Free;
  rbm     := nil;
  rbm     := TRGB32BitMap.Create(Width, Height);
  IsAlpha := _IsAlpha;
  if IsAlpha then begin
    k:=0;
    for j := 0 to Height - 1 do begin
      for i := 0 to Width - 1 do begin
        {$R-}
        cc.a := rgba^[k].a;
        if cc.a < 0 then cc.a := 0;
        if cc.a > 1 then cc.a := 1;
        cc.r   := rgba^[k].r;
        if cc.r < 0 then cc.r := 0;
        if cc.r > 1 then cc.r := 1;
        cc.g   := rgba^[k].g;
        if cc.g < 0 then cc.g := 0;
        if cc.g > 1 then cc.g := 1;
        cc.b   := rgba^[k].b;
        if cc.b < 0 then cc.b := 0;
        if cc.b > 1 then cc.b := 1;
        rbm.Set32Pixel(i, j,(DWord(round(cc.r * 255)) shl 16) or
          (DWord(round(cc.g * 255)) shl 8) or (DWord(round(cc.b * 255))) or
          (DWord(round(cc.a * 255)) shl 24));
        {$R+}
        inc(k);
      end;
    end;
  end
  else
  begin
    k:=0;
    for j := 0 to Height - 1 do begin
      for i := 0 to Width - 1 do begin
        {$R-}
        h    := 0.5 * DWord(((i shr 5) xor (j shr 5)) and 1) + 0.5;
        cc.a := rgba^[k].a;
        if cc.a < 0 then cc.a := 0;
        if cc.a > 1 then cc.a := 1;
        ma     := (1 - cc.a) * h;

        cc.r := ma + rgba^[k].r * cc.a;
        if cc.r < 0 then cc.r := 0;
        if cc.r > 1 then cc.r := 1;
        cc.g   := ma + rgba^[k].g * cc.a;
        if cc.g < 0 then cc.g := 0;
        if cc.g > 1 then cc.g := 1;
        cc.b   := ma + rgba^[k].b * cc.a;
        if cc.b < 0 then cc.b := 0;
        if cc.b > 1 then cc.b := 1;

        rbm.Set32Pixel(i, j, (DWord(round(cc.r * 255)) shl 16) or
          (DWord(round(cc.g * 255)) shl 8) or (DWord(round(cc.b * 255))) or
          (DWord(round(cc.a * 255)) shl 24));

        {$R+}
        inc(k);
      end;
    end;
  end;
//  rbm.Canvas.Fill($0000FF);
  IsCached := True;
end;

procedure TTextureGenerator.CacheGL;
var
  i, j, k: integer;
  p:     PByteArray;
  cc:    TRGBAColor;
  c:     DWord;
  ma, h: single;
begin
  if not IsLoaded then exit;

  if not IsCached then Cache(true);

  {glEnable(GL_TEXTURE_2D);
  glGenTextures(1, @texID);

  glBindTexture(GL_TEXTURE_2D, texID);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  if mipmap > 0 then begin
     if (filterType = GL_NEAREST) then begin
       glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
     end else begin
       glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
     end;
     gluBuild2DMipmaps(GL_TEXTURE_2D, format, Width, Height, GL_BGRA, GL_UNSIGNED_BYTE, @rbm.Pixels[0]);

  end else begin

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filterType);
    glTexImage2D(GL_TEXTURE_2D, 0, format, Width, Height, 0, GL_BGRA, GL_UNSIGNED_BYTE, @rbm.Pixels[0]);

  end;

  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapType);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapType);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filterType);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filterType);
             }
  rbm.Free;
  rbm:=nil;

  IsCachedGL:=true;
end;
{******************************************************************************}
procedure TTextureGenerator.UnCache;
begin
  if not IsCached then exit;
  IsCached := False;
  if rbm <> nil then begin
    rbm.Free;
    rbm := nil;
  end;
end;
{******************************************************************************}
procedure TTextureGenerator.UnCacheGL;
begin
  if not IsCachedGL then exit;
  IsCachedGL := False;
{  if glIsTexture(texID) then glDeleteTextures(1,@texID);}
  UnCache;
end;
{******************************************************************************}
procedure TTextureGenerator.SetTexture;
begin
  if IsCachedGL then begin
{    glBindTexture(GL_TEXTURE_2D,texID);}
  end else begin
{    if IsLoaded then begin
      CacheGL;
      glBindTexture(GL_TEXTURE_2D,texID);
    end else glBindTexture(GL_TEXTURE_2D,0);}
  end;
end;

{******************************************************************************}

{*******************************************************************************
                                     LIST
*******************************************************************************}
// TTextureGeneratorList
constructor TTextureGeneratorList.Create;
begin
  Count := 0;
  TextureGeneratorArray := nil;
end;

destructor TTextureGeneratorList.Destroy;
begin
  Clear;
end;

procedure TTextureGeneratorList.OnInitContext;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    item[i].OnInitContext;
end;

procedure TTextureGeneratorList.OnDestroyContext;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    item[i].OnDestroyContext;
end;

function TTextureGeneratorList.Get(index: integer): TTextureGenerator;
begin
  if (TextureGeneratorArray <> nil) and (index >= 0) and (index < Count) then
    Result := TextureGeneratorArray^[index]
  else
    Result := nil;
end;

procedure TTextureGeneratorList.Put(index: integer; const Value: TTextureGenerator);
begin
  if (index >= 0) and (index < Count) then
    TextureGeneratorArray^[index] := Value;
end;

procedure TTextureGeneratorList.Clear;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    TextureGeneratorArray^[i].Destroy;
  Count := 0;
  Freemem(TextureGeneratorArray);
  TextureGeneratorArray := nil;
end;

procedure TTextureGeneratorList.SetLength(NewLength: integer);
var
  i: integer;
begin
  if NewLength = Count then
    exit;
  if NewLength > 0 then
  begin
    if NewLength < Count then
    begin
      for i := NewLength to Count - 1 do
        TextureGeneratorArray^[i].Destroy;
    end;
    ReAllocMem(TextureGeneratorArray, sizeof(TTextureGenerator) * NewLength);
    if NewLength > Count then
    begin
      for i := Count to NewLength - 1 do
        TextureGeneratorArray^[i] := TTextureGenerator.Create;
    end;
    Count := NewLength;
  end
  else
  begin
    Clear;
  end;
end;

function TTextureGeneratorList.Add: TTextureGenerator;
begin
  SetLength(Count + 1);
  Result := TextureGeneratorArray^[Count - 1];
end;

function TTextureGeneratorList.Insert(index: integer): TTextureGenerator;
var
  i: integer;
begin
  if (index >= 0) and (index <= Count) then
  begin
    ReAllocMem(TextureGeneratorArray, sizeof(TTextureGenerator) * (Count + 1));
    if index < Count then
    begin
      System.Move(TextureGeneratorArray^[index], TextureGeneratorArray^[index + 1],
        (Count - index) * sizeof(TTextureGenerator));
    end;
    TextureGeneratorArray^[index] := TTextureGenerator.Create;
    Inc(Count);
    Result := TextureGeneratorArray^[index];
  end
  else
    Result := nil;
end;

function TTextureGeneratorList.Push: TTextureGenerator;
begin
  SetLength(Count + 1);
  Result := TextureGeneratorArray^[Count - 1];
end;

procedure TTextureGeneratorList.Pop;
begin
  Delete(Count - 1);
end;

procedure TTextureGeneratorList.Delete(index: integer);
begin
  if (index >= 0) and (index < Count) then
  begin
    TextureGeneratorArray^[index].Destroy;
    if index < Count - 1 then
    begin
      System.Move(TextureGeneratorArray^[index + 1], TextureGeneratorArray^[index],
        (Count - index - 1) * sizeof(TTextureGenerator));
    end;
    Dec(Count);
    ReAllocMem(TextureGeneratorArray, sizeof(TTextureGenerator) * Count);
  end;
end;

{******************************************************************************}

end.
{******************************************************************************}
