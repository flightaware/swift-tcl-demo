



namespace eval ::swift {
	variable hints

# hint
#
# swift::hint photos_display_hot_rating starWidth Int -> String
proc hint {proc args} {
	variable hints

	set hints($proc) $args
}

#
# guess_default_type - given a string try to suss out what
#   data type it is. first see if it is a strict int, then
#   see if it is a strict double, then see if it is a
#   string boolean. If it wasn't one of those then say it is a string.
#
proc guess_default_type {defaultValue} {
	if {[string is int -strict $defaultValue]} {
		return Int
	}

	if {[string is double -strict $defaultValue]} {
		return Double
	}

	if {[string is boolean -strict $defaultValue]} {
		return Bool
	}


	return String
}

#
# does_proc_return_something - meatball check to see if a
# tcl proc returns a value.
#
proc does_proc_return_something {proc} {
	set body [info body $proc]

	return [regexp {return } $body]
}

#
# gen - generate interface functions
#
proc gen {proc} {
	variable hints

	set args [info args $proc]

	if {[info exists hints($proc)]} {
		array set myHints $hints($proc)
	}

	set swift_name tcl::$proc
	regsub -all "::*" $swift_name "_" swift_name
	set string "\n// $swift_name\n// Wrapper for $proc\nfunc $swift_name (springboardInterp: TclInterp"

puts stderr $args
	foreach arg $args {
		append string ", "

		if {![info default $proc $arg default]} {
			unset -nocomplain default
		}

		# if there's a hint for the type, use that,
		# else if there's a default value try to
		# sniff the type out of that else say
		# it's a String
		if {[info exists myHints($arg)]} {
			set type $myHints($arg)
		} elseif {[info exists default]} {
			set type [guess_default_type $default]
		} else {
			set type String
		}
		set myTypes($arg) $type

		append string "$arg: $type"

		if {[info exists default]} {
			if {$type == "String"} {
				append string " = \"$default\""
			} else {
				append string " = $default"
			}
		}
	}

	append string ") throws"

	if {[info exists myHints(->)]} {
		append string " -> $myHints(->)"
		set return_type "$myHints(->)"
	} else {
		if {[does_proc_return_something $proc]} {
			append string " -> String"
			set return_type "String"
		}
	}

	append string " {\n"

	set body {}
	lappend body "let vec = springboardInterp.newObject()"
	lappend body "try vec.lappend(\"$proc\")"

	foreach arg $args {
		lappend body "try vec.lappend($arg)"
	}

	lappend body "Tcl_EvalObjEx(springboardInterp.interp, vec.get(), 0)"
        if [info exists return_type] {
		lappend body "return try springboardInterp.getResult()"
	}
	append string "    [join $body "\n    "]\n"
	append string "}"

		

	return $string
}

#
# enumerate_procs - recursively enumerate all procs within a namespace and
#   all of its descendant namespaces (defaulting to the top-level namespace),
#   returning them as a list
#
proc enumerate_procs {{ns ::}} {
	set list [info procs ${ns}::*]

	foreach childNamespace [namespace children $ns] {
		lappend list {*}[enumerate_procs $childNamespace]
	}

	return $list
}

}


