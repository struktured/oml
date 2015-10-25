(*
   Copyright 2015:
     Leonid Rozenberg <leonidr@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

open Util

(** Construct linear models that describe (and learn from) data.*)

(** The interface of the model constructed by a Regression procedure. *)
module type Linear_model_intf = sig
  include Util.Optional_arg_intf

  (* TODO: reorder these declarations in a way that makes more sense for
     documentation. *)

  type input
  type t

  (** [describe t] returns a string describing the regressed linear model.*)
  val describe : t -> string

  (** [eval linear_model x] Evaluate a the [linear_model] at [x].*)
  val eval : t -> input -> float

  (** [regress options pred resp] computes a linear model of [resp] based
      off of the independent variables in the design matrix [pred], taking
      into account the various method [spec]s. *)
  val regress : ?spec:spec -> input array -> resp:float array -> t

  (** [residuals t] returns the residuals, the difference between the observed
      value and the estimated value for the independent, response, values. *)
  val residuals : t -> float array

  (** [coefficients t] returns the coefficients used in the linear model. *)
  val coefficients : t -> float array

end

(** Simple one dimensional regress. *)
module Univariate : sig

  include Linear_model_intf
    with type input = float
    and type spec = float array

  (** [alpha t] a shorthand for the constant parameter used in the regression.
      Equivalent to [(coefficients t).(0)] *)
  val alpha : t -> float

  (** [beta t] a shorthand for the linear parameter used in the regression.
      Equivalent to [(coefficients t).(1)] *)
  val beta : t -> float

  (** [confidence_interval linear_model alpha x] Use the [linear_model] to
      construct confidence intervals at [x] at an [alpha]-level of significance.
  *)
  val confidence_interval : t -> alpha:float -> input -> float * float

  (** [prediction_interval linear_model alpha x] Use the [linear_model] to
      construct prediction intervals at [x] at an [alpha]-level of significance.
  *)
  val prediction_interval : t -> alpha:float -> input -> float * float

end

type lambda_spec =
  | Spec of float         (** Use this specific value. *)
  | From of float array   (** Choose the value in the array with the lowest Leave-One-Out-Error. *)

type multivariate_spec =
  { add_constant_column : bool          (** Instructs the method to efficiently insert a colum of 1's into the
                                            design matrix for the constant term. *)
  ; lambda_spec : lambda_spec option    (** How to optionally determine the ridge parameter. *)
  }

(** Multi-dimensional input regression, with support for Ridge regression. *)
module Multivariate : sig

  include Linear_model_intf
    with type input = float array
    and type spec = multivariate_spec

end

type tikhonov_spec =
  { regularizer : float array array   (** The regularizing matrix. *)
  ; lambda_spec : lambda_spec option  (** How to optionally determine the ridge parameter. *)
  }

(** Multi-dimensional input regression with a matrix regularizer.
  described {{:https://en.wikipedia.org/wiki/Tikhonov_regularization} here}. *)
module Tikhonov : sig

  include Linear_model_intf
    with type input = float array
    and type spec = tikhonov_spec

end
