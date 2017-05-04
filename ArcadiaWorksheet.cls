(use 'arcadia.core)
(use 'arcadia.linear)
(use 'arcadia.introspection)
(use 'clojure.repl)

; Procedural Geometry
(import UnityEngine.GameObject)
(import UnityEngine.Mesh)
(import UnityEngine.MeshFilter)
(import UnityEngine.MeshRenderer)
(import UnityEngine.Mathf)
(import UnityEngine.Vector2)
(import UnityEngine.Vector3)

(def TWO_PI (* 2 (.. Mathf PI)))

(defn polygon-verts-2d 
	"returns 2d vectors of a unit polygon with n sides" 
	[sides]
	(->> 
		(range sides)
		(map (fn [n] [
			(.. Mathf (Cos (* (/ TWO_PI sides) n)))
		 	(.. Mathf (Sin (* (/ TWO_PI sides) n)))
	 	]))
	 	(cons [0 0])
	 	(reverse)))

(defn polygon-verts [sides]
	 	(map 
	 		(fn [[x y]] (v3 x 0 y))
	 		(polygon-verts-2d sides)))


(defn polygon-uvs [sides]
	 	(map 
	 		(fn [[x y]] (v2 x y))
	 		(polygon-verts-2d sides)))

(defn polygon-tris [sides]
	(->>
		(range sides)
		(map (fn [n] [ 
			n 
			(mod (+ 1 n) sides) 
			sides
		]))
		flatten))

(defn generate-polygon-mesh [mesh sides]
	(.. mesh (Clear))
	(set! (.. mesh vertices) (into-array Vector3 (polygon-verts sides)))
	(set! (.. mesh uv) (into-array Vector2 (polygon-uvs sides)))
	(set! (.. mesh triangles) (into-array Int32 (polygon-tris sides))))

(defn polygon 
	"returns a GameObject containing a unit polygon with n sides"
	([sides]
		(let [
			mesh (Mesh.)
			go (GameObject.)
			mf (cmpt+ go MeshFilter)
			mr (cmpt+ go MeshRenderer)
		]
		(set! (.. go name) (str "poly-" sides))
		(set! (.. mf mesh) mesh)
		(generate-polygon-mesh mesh sides)
		go))
	([go sides] 
		(generate-polygon-mesh (.. (cmpt go MeshFilter) mesh) sides)
		go))
	
;; handle OSC
(def osc (atom {
	:knobs (zipmap (range 1 33) (repeat 0))
	}))

;(get (:knobs @osc) 1)

(def ob (polygon 0))

(defn handle-msg [msg] 
	(let [[i v] (vec (.. msg (get_args)))]
		(swap! osc assoc-in [:knobs i] v)
		(when (= i 1) (polygon ob v))))

(defn on-bcr2000 [msg] (handle-msg msg))

(def osc-go (object-named "OSC"))
(def osc-in (cmpt osc-go "OscIn"))
(.. osc-in (Map "/bcr2000" on-bcr2000))

