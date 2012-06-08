unit uNlOpt;

interface
  uses Windows;

{ Copyright (c) 2007-2011 Massachusetts Institute of Technology
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
}

type nlopt_func = function(n : Cardinal; const x : PDouble;
			     gradient : PDouble; { nil if not needed }
			     func_data : Pointer) : double; stdcall;

type nlopt_mfunc = procedure(m : Cardinal; result : PDouble;
			     n : Cardinal; const x : PDouble;
			     gradient : PDouble; {/* NULL if not needed */}
			     func_data : Pointer); stdcall;

type nlopt_algorithm = (
     {Naming conventions:

        NLOPT_ (G/L) (D/N)_
	    = global/local derivative/no-derivative optimization,
              respectively

	*_RAND algorithms involve some randomization.

	*_NOSCAL algorithms are *not* scaled to a unit hypercube
	         (i.e. they are sensitive to the units of x)
	*/  }

     NLOPT_GN_DIRECT = 0,
     NLOPT_GN_DIRECT_L,
     NLOPT_GN_DIRECT_L_RAND,
     NLOPT_GN_DIRECT_NOSCAL,
     NLOPT_GN_DIRECT_L_NOSCAL,
     NLOPT_GN_DIRECT_L_RAND_NOSCAL,

     NLOPT_GN_ORIG_DIRECT,
     NLOPT_GN_ORIG_DIRECT_L,

     NLOPT_GD_STOGO,
     NLOPT_GD_STOGO_RAND,

     NLOPT_LD_LBFGS_NOCEDAL,

     NLOPT_LD_LBFGS,

     NLOPT_LN_PRAXIS,

     NLOPT_LD_VAR1,
     NLOPT_LD_VAR2,

     NLOPT_LD_TNEWTON,
     NLOPT_LD_TNEWTON_RESTART,
     NLOPT_LD_TNEWTON_PRECOND,
     NLOPT_LD_TNEWTON_PRECOND_RESTART,

     NLOPT_GN_CRS2_LM,

     NLOPT_GN_MLSL,
     NLOPT_GD_MLSL,
     NLOPT_GN_MLSL_LDS,
     NLOPT_GD_MLSL_LDS,

     NLOPT_LD_MMA,

     NLOPT_LN_COBYLA,

     NLOPT_LN_NEWUOA,
     NLOPT_LN_NEWUOA_BOUND,

     NLOPT_LN_NELDERMEAD,
     NLOPT_LN_SBPLX,

     NLOPT_LN_AUGLAG,
     NLOPT_LD_AUGLAG,
     NLOPT_LN_AUGLAG_EQ,
     NLOPT_LD_AUGLAG_EQ,

     NLOPT_LN_BOBYQA,

     NLOPT_GN_ISRES,

  {new variants that require local_optimizer to be set,
	not with older constants for backwards compatibility }
     NLOPT_AUGLAG,
     NLOPT_AUGLAG_EQ,
     NLOPT_G_MLSL,
     NLOPT_G_MLSL_LDS,

     NLOPT_LD_SLSQP,

     NLOPT_NUM_ALGORITHMS {/* not an algorithm, just the number of them */}
);

function nlopt_algorithm_name(a : nlopt_algorithm): PAnsiChar; stdcall; external 'libnlopt-0.dll' name 'nlopt_algorithm_name@4';

type nlopt_result =  Integer;
const
     NLOPT_FAILURE = -1; {/* generic failure code */}
     NLOPT_INVALID_ARGS = -2;
     NLOPT_OUT_OF_MEMORY = -3;
     NLOPT_ROUNDOFF_LIMITED = -4;
     NLOPT_FORCED_STOP = -5;
     NLOPT_SUCCESS = 1; {/* generic success code */ }
     NLOPT_STOPVAL_REACHED = 2;
     NLOPT_FTOL_REACHED = 3;
     NLOPT_XTOL_REACHED = 4;
     NLOPT_MAXEVAL_REACHED = 5;
     NLOPT_MAXTIME_REACHED = 6;


const NLOPT_MINF_MAX_REACHED = NLOPT_STOPVAL_REACHED;

procedure nlopt_srand(seed : LongInt); stdcall; external 'libnlopt-0.dll' name 'nlopt_srand@4';
procedure nlopt_srand_time(); stdcall; external 'libnlopt-0.dll' name 'nlopt_srand_time@0';

procedure nlopt_version(major : PInteger; minor: PInteger; bugfix : PInteger); stdcall; external 'libnlopt-0.dll' name 'nlopt_version@12';

{/*************************** OBJECT-ORIENTED API **************************/
/* The style here is that we create an nlopt_opt "object" (an opaque pointer),
   then set various optimization parameters, and then execute the
   algorithm.  In this way, we can add more and more optimization parameters
   (including algorithm-specific ones) without breaking backwards
   compatibility, having functions with zillions of parameters, or
   relying non-reentrantly on global variables.*/
}

type Nlopt_opt   = Pointer;

{/* the only immutable parameters of an optimization are the algorithm and
   the dimension n of the problem, since changing either of these could
   have side-effects on lots of other parameters */}

function nlopt_create(algorithm : nlopt_algorithm; n : Cardinal) : Nlopt_opt; stdcall; external 'libnlopt-0.dll' name 'nlopt_create@8';
procedure nlopt_destroy(opt : Pointer ); stdcall; external 'libnlopt-0.dll' name 'nlopt_destroy@4';
function nlopt_copy(const opt : nlopt_opt) : nlopt_opt; stdcall; external 'libnlopt-0.dll' name 'nlopt_copy@4';

function nlopt_optimize(opt : nlopt_opt; x : PDouble; opt_f : PDouble) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_optimize@12';

function nlopt_set_min_objective(opt : nlopt_opt; f : nlopt_func;
						  f_data : Pointer) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_min_objective@12';
function nlopt_set_max_objective(opt : nlopt_opt; f : nlopt_func;
						  f_data : Pointer) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_max_objective@12';

function nlopt_get_algorithm(const opt : nlopt_opt) : nlopt_algorithm; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_algorithm@4';
function nlopt_get_dimension(const opt : nlopt_opt) : Cardinal; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_dimension@4';

{ constraints: }

function nlopt_set_lower_bounds(opt : nlopt_opt;
						 const lb : PDouble) : nlopt_algorithm; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_lower_bounds@8';
function nlopt_set_lower_bounds1(opt : nlopt_opt; lb : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_lower_bounds1@12';
function nlopt_get_lower_bounds(const opt: nlopt_opt; lb : PDouble) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_lower_bounds@8';
function nlopt_set_upper_bounds(opt : nlopt_opt; const ub : PDouble) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_upper_bounds@8';
function nlopt_set_upper_bounds1(opt : nlopt_opt; ub : Double): nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_upper_bounds1@12';
function nlopt_get_upper_bounds(const opt : nlopt_opt; ub : PDouble): nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_upper_bounds@8';

function nlopt_remove_inequality_constraints(opt : nlopt_opt) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_remove_inequality_constraints@4';
function nlopt_add_inequality_constraint(opt : nlopt_opt;
							  fc : nlopt_func;
							  fc_data : Pointer;
							  tol : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_add_inequality_constraint@20';
function nlopt_add_inequality_mconstraint(opt : nlopt_opt;
							    m : Cardinal;
							    fc : nlopt_mfunc;
							    fc_data : Pointer;
							    const tol : PDouble) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_add_inequality_mconstraint@20';

{ stopping criteria: }

function nlopt_set_stopval(opt : nlopt_opt; stopval : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_stopval@12';
function nlopt_get_stopval(const opt : nlopt_opt) : double; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_stopval@4';

function nlopt_set_ftol_rel(opt : nlopt_opt; tol : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_ftol_rel@12';
function nlopt_get_ftol_rel(const opt : nlopt_opt) : double; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_ftol_rel@4';
function nlopt_set_ftol_abs(opt : nlopt_opt; tol : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_ftol_abs@12';
function nlopt_get_ftol_abs(const opt : nlopt_opt) : double; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_ftol_abs@4';

function nlopt_set_xtol_rel(opt : nlopt_opt; tol : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_xtol_rel@12';
function nlopt_get_xtol_rel(const opt : nlopt_opt) : double; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_xtol_rel@4';
function nlopt_set_xtol_abs1(opt : nlopt_opt; tol : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_xtol_abs1@12';
function nlopt_set_xtol_abs(opt : nlopt_opt; const tol : PDouble) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_xtol_abs@8';
function nlopt_get_xtol_abs(const opt : nlopt_opt; tol : PDouble) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_xtol_abs@8';

function nlopt_set_maxeval(opt : nlopt_opt; maxeval : Integer) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_maxeval@8';
function nlopt_get_maxeval(const opt : nlopt_opt) : Integer; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_maxeval@4';

function nlopt_set_maxtime(opt : nlopt_opt; maxtime : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_maxtime@12';
function nlopt_get_maxtime(const opt : nlopt_opt) : double; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_maxtime@4';

function nlopt_force_stop(opt : nlopt_opt) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_force_stop@4';
function nlopt_set_force_stop(opt : nlopt_opt; val : Integer) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_force_stop@8';
function nlopt_get_force_stop(const opt : nlopt_opt) : Integer; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_force_stop@4';

{ more algorithm-specific parameters }

function nlopt_set_local_optimizer(opt : nlopt_opt;
						    const local_opt : nlopt_result) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_local_optimizer@8';

function nlopt_set_population(opt : nlopt_opt; pop : Cardinal) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_population@8';
function nlopt_get_population(const opt : nlopt_opt) : Cardinal; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_population@4';

function nlopt_set_vector_storage(opt : nlopt_opt; dim : Cardinal) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_vector_storage@8';
function nlopt_get_vector_storage(const opt : nlopt_opt) : Cardinal; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_vector_storage@4';

function nlopt_set_default_initial_step(opt : nlopt_opt; const x : PDouble) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_default_initial_step@8';
function nlopt_set_initial_step( opt : nlopt_opt; const dx : PDouble ) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_initial_step1@12';
function nlopt_set_initial_step1(opt : nlopt_opt; dx : double) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_set_initial_step1@12';
function nlopt_get_initial_step(const opt : nlopt_opt;
						 const x : PDouble; dx : PDouble) : nlopt_result; stdcall; external 'libnlopt-0.dll' name 'nlopt_get_initial_step@12';

{ the following are functions mainly designed to be used internally
   by the Fortran and SWIG wrappers, allow us to tel nlopt_destroy and
   nlopt_copy to do something to the f_data pointers (e.g. free or
   duplicate them, respectively) }
type nlopt_munge = function( p : Pointer) : Pointer; stdcall;

procedure nlopt_set_munge(opt : nlopt_opt;
				  munge_on_destroy : nlopt_munge;
				  munge_on_copy : nlopt_munge); stdcall; external 'libnlopt-0.dll' name 'nlopt_set_munge@12';

implementation

end.
