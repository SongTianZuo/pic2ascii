{
    图片 到 ascii图片的转换
    convert picture to ascii text picture

    support format: png, jpg(jpeg), bmp
}
program pic2ascii;
{$mode objfpc}


uses
    FPReadPNG, FPReadBMP, fpreadjpeg,
     {$ifndef UseFile}classes,{$endif}
     FPImage, sysutils;

const
     ascii_chars : string = '$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,"^`''. '; //用来替代像素的字符集合
     //txtSize : integer = 100; //生在 ascii 图像的最大边的高度（未实现), output txt file max(width,height) unfinished


{全局变量, global vars}
var
    img : TFPMemoryImage;
    picFile, txtFile : string;

{初始化init}
procedure init();
begin
    if paramcount = 1 then
    begin
        picFile := paramstr(1);
        txtFile := 'pic2ascii.txt';
        img := TFPMemoryImage.Create(0,0);
    end
    else if paramcount = 2 then
    begin
        picFile := paramstr(1);
        txtFile := paramstr(2);
        img := TFPMemoryImage.Create(0,0);
    end
    else
    begin
        writeln('example: pic2ascii hello.jpg');
        writeln('example: pic2ascii hello.jpg hello.txt');
        Halt(1);
    end;
end;

{endswith}
function EndsWith(const src: String;const Substr :String):Boolean;
var
I,I2: Integer;
begin
  Result := true;
  I2 := Length(SubStr);
  i:=length(src);
  if i<i2 then exit (false);
  
  for I := 1 to i2 do begin
  if not(src[length(src)-i2+i] = Substr[i]) then begin
        Result := false;
        exit;
    end;
    end;
end;

{ReadImage}
procedure ReadImage;
{$ifndef UseFile}var str : TStream;{$endif}
t:string;
reader : TFPCustomImageReader;
begin
    T := upcase (picFile);
    reader:=nil;
    if endsWith(t,'.BMP') then
      Reader := TFPReaderBMP.Create
    else if endswith(t,'.JPEG') or endswith(t,'.JPG') then
      Reader := TFPReaderJPEG.Create
    else if endswith(t,'.PNG') then
      Reader := TFPReaderPNG.Create
    else
      begin
      Writeln('Unknown file format : ',T);
      Halt(1);
    end;
    if assigned (reader) then
        begin img.LoadFromFile (picFile, Reader); Reader.Free; end
     else
    {$ifdef UseFile}
     img.LoadFromFile (picFile);
    {$else}
    if fileexists (picFile) then
    begin
        str := TFileStream.create (picFile,fmOpenRead);
        try
            img.loadFromStream (str);
        finally
            str.Free;
        end;
    end
    else
    begin
        writeln ('File ',picFile,' doesn''t exists!');
        Halt(1);
    end;
    {$endif}
end;

{get_chars}
function get_chars(color : TFPColor):char;
var
    l:integer;
    gray : longint;
    u : double;
    r,g,b,alpha:integer;
begin
    alpha := (color.alpha and $ff00) shr 8;
    r := (color.red and $ff00) shr 8;
    g := (color.Green and $ff00) shr 8;
    b :=  (color.Blue and $ff00)shr 8;
    if alpha = 0 then exit(' ');
    l := length(ascii_chars);
    gray := trunc( 0.2126 * r + 0.7152 * g + 0.0722 * b );
    u := alpha / l ;//将256个像素均分给字符
    if trunc(gray/u) < l then
        exit ( ascii_chars[ trunc( gray / u ) + 1 ])
    else
        exit (' ');
end;


{ConvertImage}
procedure ConvertImage;
var
    outputHeight, outputWidth, h, w, x, y:integer;
    f : text;
begin
    h := img.Height;
    w := img.Width;

    outputHeight:=h;
    outPutWidth:=w;

    {
    //To Do: 按比例缩放图像
    // To Do : resize picture here (unfinished)
    }
    
    assign(f,txtFile);
    rewrite(f);
    for y:= 1 to outputHeight do
    begin
        for x:=1 to outPutWidth do 
            write(f,get_chars(img.colors[x-1,y-1])); 
        writeln(f);
    end;
    close(f);
end;

{clean}
procedure Clean;
begin
  Img.Free;
end;

{main}
begin
    try
        //writeln ('Initing');
        Init;
        //writeln ('Reading image');
        ReadImage;
      // writeln ('Convert image');
        ConvertImage;
       //writeln ('Clean up');
        Clean;
    except
        on e : exception do
            writeln ('Error: ',e.message);
    end;
end.