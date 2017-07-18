(do 
  (do ; REPL convenience
    (use 'clojure.repl)
    (use '[clojure.pprint :only (pprint)])
    (defn ffn "find function - pretty prints the result of call apropos with given string" 
      [s] (pprint (apropos s)))
    (comment ;usage
      (ffn "con") ;find fns containing "con" 
      ))
  
  (do ; Procedural Geometry
    (use 'arcadia.core)
    (use 'arcadia.linear)
    (use 'arcadia.introspection)
    (import UnityEngine.GameObject)
    (import UnityEngine.Mesh)
    (import UnityEngine.MeshFilter)
    (import UnityEngine.MeshRenderer)
    (import UnityEngine.Mathf)
    (import UnityEngine.Vector2)
    (import UnityEngine.Vector3)
    
    (defn new-go-mesh "returns a new GameObject with mesh" 
      ([] (let [mesh (Mesh.)
                go (GameObject.)
                mf (cmpt+ go MeshFilter)
                mr (cmpt+ go MeshRenderer)]
            (set! (.. mf mesh) mesh)
            go))
      ([go-name] (let [go (new-go-mesh)]
                   (set! (.. go name) go-name)
                   go)))
    
    (defn mesh "returns mesh given GameObject or name of GameObject"
      [go-or-name]
      (let [go (if (string? go-or-name) 
                 (object-named go-or-name)
                 go-or-name)]
        (.. (cmpt go MeshFilter) mesh)))
    
    (defn update-mesh! "clears the mesh and sets verts, uvs and tris given a mesh or GameObject"
      [go-or-mesh verts uvs tris]
      (let [is-mesh (= Mesh(type go-or-mesh))
            mesh (if is-mesh go-or-mesh (mesh go-or-mesh))]
        (.. mesh (Clear))
        (set! (.. mesh vertices) (into-array Vector3 verts))
        (set! (.. mesh uv) (into-array Vector2 uvs))
        (set! (.. mesh triangles) (into-array Int32 tris))))
    
    
    ;Polygon
    (def TWO_PI (* 2 (.. Mathf PI)))
    
    (defn polygon-verts-2d "returns a list of 2d vectors: vertices(including center) of a unit polygon with n sides centered at [0,0]" 
      [sides]
      (->> (range sides)
           (map 
             (fn [n] 
               [(.. Mathf (Cos (* (/ TWO_PI sides) n)))
                (.. Mathf (Sin (* (/ TWO_PI sides) n)))
                ]))
           (cons [0 0])
           (reverse)))
    
    (defn polygon-tris "returns a list of ints representing triangles consisting of vertex indices, considering the center vertex"
      [sides]
      (->>
        (range sides)
        (map (fn [n] 
               [n 
                (mod (+ 1 n) sides) 
                sides]))
        flatten))
    
    (defn polygon-tris-flipped "returns a list of ints representing triangles(normals flipped) consisting of vertex indices, considering the center vertex"
      [sides]
      (->>
        (range sides)
        (map (fn [n] [ 
                      sides
                      (mod (+ 1 n) sides) 
                      n
                      ]))
        flatten))
    
    (defn verts-2d->v3-xy "returns a list of Vector3 from verts-2d on x-y-plane"
      [verts-2d]
      (->> verts-2d
           (map (fn [[x y]] (v3 x 0 y)))))
    
    (defn verts-2d->v2 "returns a list of Vector2 from verts-2d"
      [verts-2d]
      (->> verts-2d
           (map #(apply v2 %))))
    
    (defn generate-polygon-mesh! "updates mesh with geometry for polygon of n sides"
      [mesh sides]
      (let [verts-2d (polygon-verts-2d sides)]
      (update-mesh! mesh 
                    (verts-2d->v3-xy verts-2d)
                    (verts-2d->v2 verts-2d)
                    (polygon-tris sides))))
    
    (defn polygon 
      "returns a GameObject containing a n-sided polygon of radius 1 on the xy plane"
      ([sides]
       (let [go (new-go-mesh (str "poly-" sides))
             mesh (mesh go)]
         (generate-polygon-mesh! mesh sides)
         go))
      ([go sides] 
       (generate-polygon-mesh! (mesh go) sides)
       go))
    
    (comment ;usage
      (new-go-mesh "heyo") ;new GameObject named "heyo" which has been added to the scene
      (mesh (object-named "heyo")) ;the mesh attached to the GameObject named "heyo"
      (mesh "heyo") ;the mesh attached to the GameObject named "heyo"
      (polygon-verts-2d 3) ;([-0.4999999 -0.8660254] [-0.5000001 0.8660254] [1.0 0.0] [0 0])
      (verts-2d->v3-xy [[0 1][2 3]]) ;(#unity/Vector3 [0.0 0.0 1.0] #unity/Vector3 [2.0 0.0 3.0])
      (verts-2d->v2 [[0 1][2 3]]) ;(#unity/Vector2 [0.0 1.0] #unity/Vector2 [2.0 3.0])
      (polygon-tris 3) ;(0 1 3 1 2 3 2 0 3)
      (polygon-tris-flipped 3) ;(3 1 0 3 2 1 3 0 2)
      (polygon 5) ;new GameObject named "poly-5" with a pentagon or radius 1 on xy plane
      )
    (doc new-go-mesh)
    (doc mesh)
    (doc update-mesh!)
    
    (doc polygon-verts-2d)
    (doc polygon-tris)
    (doc polygon-tris-flipped)
    (doc verts-2d->v3-xy)
    (doc verts-2d->v2)
    (doc generate-polygon-mesh!)
    (doc polygon)
    "Procedural Geometry ready")
  
  
  
  (defn dod-verts [r]
    (let [
          phi (/ (+ 1 (Mathf/Sqrt 5)) 2)
          sqrt3 (Mathf/Sqrt 3)
          a (/ r sqrt3)
          -a (* a -1)
          b (/ r (* sqrt3 phi))
          -b (* b -1)
          c (/ (* r phi) sqrt3)
          -c (* c -1)]
      [
       [ a  a  a] [-a  a  a] [ a -a  a] [ a  a -a]
       [-a -a  a] [ a -a -a] [-a  a -a] [-a -a -a]
       [ 0  b  c] [ 0 -b  c] [ 0  b -c] [ 0 -b -c]
       [ b  c  0] [-b  c  0] [ b -c  0] [-b -c  0]
       [ c  0  b] [ c  0 -b] [-c  0  b] [-c  0 -b]]))
  
  (def pents 
    [[0 8 1 13 12] [0 12 3 17 16] [0 16 2 9 8]
     [1 8 9 4 18] [1 18 19 6 13] [3 12 13 6 10]
     [2 14 15 4 9] [2 16 17 5 14] [3 10 11 5 17]
     [4 15 7 19 18] [5 11 7 15 14] [6 19 7 11 10]])
  
  (defn pentagon 
    "returns a GameObject"
    [i verts-v3 uvs tris]	
    (let [[go mesh] (new-go-mesh (str "pent-" i))]
      (update-mesh! mesh verts-v3 uvs tris)
      go))
  
  (defn add-vecs [[a1 b1 c1] [a2 b2 c2]] [(+ a1 a2) (+ b1 b2) (+ c1 c2)])
  (defn div-vec-scalar [v s] (map #(/ % s) v))
  
  ; TODO make each pentagon its own GameObject centered at center
  (defn make-dodecahedron [] 
    (map (fn [p i] 
           (let [
                 verts (map (fn [i] (nth (dod-verts 100) i)) p)
                 center (div-vec-scalar 
                          (reduce add-vecs verts)
                          (count verts))
                 verts-v3 (map #(apply v3 %) (conj verts center))
                 uvs (polygon-uvs 5)
                 tris (polygon-tris 5)
                 ]
             (pentagon i verts-v3 uvs tris)
             )
           
           ) (take 12 pents) (range)))
  
  
  
  
  
  
  
  
  
  
  (import Spout.SpoutReceiver)
  (import Spout.Spout)
  
  (defn list-spout-senders [] 
    (map #(. % name) (.. Spout instance activeSenders)))
  
  (defn set-spout-sender [go-name i]
    (let [sr (cmpt (object-named go-name) SpoutReceiver)
          senders (list-spout-senders)]
      (set! (.. sr sharingName) (nth senders (mod i (count senders))))))
  
  ; (set-spout-sender "Cube3" 5)
  
  ; (methods SpoutReceiver)
  
  
  
  
  ;; handle OSC
  (def osc (atom {
                  :knobs (zipmap (range 1 33) (repeat 0))
                  :sines {1 {:f 0 :a 0}}
                  }))
  
  ;(get (:knobs @osc) 1)
  
  ;(def ob (polygon 5))
  
  
  (defn set-fov [camera-name fov]
    (let [cam (cmpt (object-named camera-name) "Camera")]
      (set! (.. cam fieldOfView) fov)))
  
  ; (set-fov "SpoutCam" 50)
  (defn handle-msg [msg] 
    (let [[i v] (vec (.. msg (get_args)))]
      (swap! osc assoc-in [:knobs i] v)
      (when (= i 1) (set-fov "SpoutCam" v))
      (when (= i 2) (set-fov "CameraL" v))
      (when (= i 3) (set-fov "CameraR" v))
      (when (= i 4) (set-spout-sender "Cube" v))
      (when (= i 5) (set-spout-sender "Cube2" v))
      (when (= i 6) (set-spout-sender "Cube3" v))
      ))
  
  (defn handle-attack [msg] 
    (let [[v] (vec (.. msg (get_args)))
          n (:attack @osc)]
      (swap! osc assoc :attack (inc n))
      (set-spout-sender "Cube" n)
      )		
    )
  
  (defn on-sines [msg]
    (let [args (vec (.. msg (get_args)))
          [n freq amp] args]
      (swap! osc assoc-in [:sines n] { :f freq :a amp })))
  
  (defn on-bcr2000 [msg] (handle-msg msg))
  (defn on-attack [msg] (handle-attack msg))
  
  (def osc-go (object-named "OSC"))
  (def osc-in (cmpt osc-go "OscIn"))
  (.. osc-in (Map "/bcr2000" on-bcr2000))
  ; (.. osc-in (Map "/attack" on-attack))
  ; (.. osc-in (Map "/sines" on-sines))
  
  
  ; state of inputs
  (def s 
    (atom 
      {
       :knobs (zipmap (range 1 33) (repeat 0))
       :space-mouse {
                     :go nil ;the GameObject to manipulate
                     :translation (v3 0)
                     :rotation (qt)
                     }
       :keys {:space false}}))
  
  ; (pprint (:space-mouse @s))
  
  
  ; SpaceNavigator
  (import SpaceNavigatorDriver.SpaceNavigator)
  (SpaceNavigator/SetRotationSensitivity 1)
  (SpaceNavigator/SetTranslationSensitivity 1)
  
  ; Keyboard
  (import UnityEngine.Input)
  (import UnityEngine.KeyCode)
  
  
  ; (defn u [go] ;translate/rotate
  ; 	(.. go transform (Translate (.. SpaceNavigator Translation)))
  ; 	(.. go transform (Rotate (.. SpaceNavigator Rotation eulerAngles))))
  
  (defn u [go]
    (swap! s assoc :space-mouse {
                                 :translation (.. SpaceNavigator Translation)
                                 :rotation (.. SpaceNavigator Rotation)})
    (swap! s assoc :keys {
                          :space (Input/GetKey (. KeyCode Space))
                          :a (Input/GetKey (. KeyCode A))
                          :b (Input/GetKey (. KeyCode B))
                          :c (Input/GetKey (. KeyCode C))
                          }))
  ; Track keyboard and spacemouse state
  ; (def state-obj (GameObject. "StateObj"))
  ; (hook+ state-obj :update #(u %))
  
  
  
  ; spawn a cube for each key
  ; move the cube if corresponding key is down while manipulating spacemouse
  ; (->> [:a :b :c :space]
  ;      (map 
  ;        #(let 
  ;           [
  ;            go (create-primitive :cube)
  ;            u (fn [go] 
  ;                (let 
  ;                  [
  ;                   {t :translation r :rotation} 
  ;                   (:space-mouse @s)
                    
  ;                   k (get-in @s [:keys %])]
  ;                  (if k 
  ;                    (do  
  ;                      (set! 
  ;                        (.. go transform position) 
  ;                        t)
  ;                      (set! 
  ;                        (.. go transform rotation) 
  ;                        r)))))
  ;            ]
  ;           (hook+ go :update u))))

  
  ; (defn update-sphere [go] 
  ;   (let [{{f :f a :a} 1} (:sines @osc)]
  ;     (set! (.. go transform position) (v3 5 (* 100000 a) 0))
  ;     ))
  
  ; (let [go (create-primitive :sphere)]
  ;   (hook+ go :update #(update-sphere %))
  ;   )
  

  (defn mk-spheres [num]
    (let [keys (range 1 (+ num 1))]
      (zipmap keys (map (fn [k] (create-primitive :sphere)) keys))))
  
  (def spheres (mk-spheres 20))

  (defn on-sines [msg]
    (let [args (vec (.. msg (get_args)))
          [n freq amp] args
          sphere (spheres n)]
      (set! (.. sphere transform position) 
              (v3 (* freq 0.01) (* 100 amp) 0))
      ))

  ; (Mathf/Pow 2 10)
  ; (->> (range 15) (map #(Mathf/Pow 2 %)) (map #(Mathf/Log % 2)))
  ; (methods Mathf)

  (.. osc-in (Map "/sines" #(on-sines %)))
  
  
  
      )







; TODO: sketch geometry for some spec types and functions
; (defnvr some-func "defines a fn and adds a geometric
; representation of it to the scene"
;  [args] (body))
; (def fnvrs (atom {"fn1" {:fn fn1 :go gameobj} ...}) )

; {:fn-vrs {"fn1" {:fn fn1 :go GameObject}}
;  :val-vrs {"val1" {:v 123 :go GameObject}}
;  :controls #{[:number-dial "val1"]}
;  :connections #{["val1" ["fn1" 0]]}}

; do this for vals (state) too. it all goes in one atom probably


; goal is to teach someone to program in a shared VR
; one shared camera position, a set of hands for each player
