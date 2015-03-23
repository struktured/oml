(** Create generators for sampling from specified distributions. *)

(** [normal ?seed mean std ()] creates a generator that will return variables
    from the Normal distribution of [mean] and [std] (standard deviation).*)
val normal : ?seed:int array -> mean:float -> std:float -> unit -> (unit ->
  float)

(** [normal_std seed ()] is equivalent to [normal seed ~mean:0.0 ~std:1.0 ()].*)
val normal_std : ?seed:int array -> unit -> (unit -> float)
  