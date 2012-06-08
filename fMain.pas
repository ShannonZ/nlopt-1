unit fMain;

interface

uses
  uNlOpt,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

type
  pmy_constraint_data = ^my_constraint_data;
  my_constraint_data = record
  a : double;
  b : double;
end;

function myfunc( n : Cardinal; const x : PDouble; grad : PDouble; my_func_data : Pointer) : Double; stdcall;
var
  x2 : Array of Double;
  grad2 : Array of Double;
begin

  SetLength(x2, n);
  CopyMemory(x2,x,n*sizeof(double));

   SetLength(grad2, n);
  CopyMemory(grad2,grad,n*sizeof(double));

  if grad <> nil then begin
    grad2[0] := 0.0;
    grad2[1] := 0.5 / sqrt(x2[1]);
  end;
  Result := sqrt(x2[1]);
end;

function myconstraint(n : Cardinal; const x : PDouble; grad : PDouble; data : Pointer) : double; stdcall;
var
  d : Pmy_constraint_data;
  a, b : double;

  x2 : Array of Double;
  grad2 : Array of Double;
begin

  SetLength(x2, n);
  CopyMemory(x2,x,n*sizeof(double));

  SetLength(grad2, n);
  CopyMemory(grad2,grad,n*sizeof(double));

   d := Pmy_constraint_data(data);
    a := d.a;
    b := d.b;
    if grad <> nil then begin
        grad2[0] := 3*a * (a*x2[0] + b) * (a*x2[0] + b);
        grad2[1] := -1.0;
    end;

    Result := ((a*x2[0] + b) * (a*x2[0] + b) * (a*x2[0] + b) - x2[1]);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  opt : nlopt_opt;
  lb : Array[0..1] of Double;
  data : Array[0..1] of my_constraint_data;
  x : Array[0..1] of Double;

  maj, min, bug : PInteger;

  minf : PDouble;

begin

  GetMem( minf, sizeof(double));

  GetMem( maj, sizeof(integer));
  GetMem( min, sizeof(integer));
  GetMem( bug, sizeof(integer));

  lb[0] := (9999999*-1);
  lb[1] := 0;

  data[0].a := 2;
  data[0].b := 0;

  data[1].a := -1;
  data[1].b := 1;

  //SetLength(x, 2);
  x[0] := 0.333334;
  x[1] := 0.296296;

  nlopt_version( maj, min, bug );

  opt := nlopt_create(NLOPT_LD_MMA,2);
  nlopt_set_lower_bounds(opt, @lb[0]);
  nlopt_set_min_objective(opt, myfunc, Pointer(0));

  nlopt_add_inequality_constraint(opt, myconstraint, @data[0], 1e-8);
  nlopt_add_inequality_constraint(opt, myconstraint, @data[1], 1e-8);

  nlopt_set_xtol_rel(opt, 1e-4);

  if (nlopt_optimize(opt, @x[0], minf) < 0) then
    ShowMessage('nlopt failed!\n')
  else
    ShowMessage('found minimum at {' + FloatToStr(x[0]) + ',' + FloatToStr(x[1]) + '} ' + FloatToStr(minf^));

  nlopt_destroy( opt );

end;

end.
