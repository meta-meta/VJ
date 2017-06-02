(do 
  (use 'clojure.repl)
  (use '[clojure.pprint :only (pprint)])
  (use 'arcadia.core)
  (use 'arcadia.linear)
  (use 'arcadia.introspection)

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
    (->> (range sides)
         (map 
           (fn [n] 
             [(.. Mathf (Cos (* (/ TWO_PI sides) n)))
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
      (map (fn [n] 
             [n 
              (mod (+ 1 n) sides) 
              sides]))
      flatten))
  
  (defn polygon-tris-flipped [sides]
    (->>
      (range sides)
      (map (fn [n] [ 
                    sides
                    (mod (+ 1 n) sides) 
                    n
                    ]))
      flatten))
  
  (defn update-mesh [mesh verts uvs tris]
    (.. mesh (Clear))
    (set! (.. mesh vertices) (into-array Vector3 verts))
    (set! (.. mesh uv) (into-array Vector2 uvs))
    (set! (.. mesh triangles) (into-array Int32 tris)))
  
  (defn generate-polygon-mesh [mesh sides]
    (update-mesh mesh 
                 (polygon-verts sides)
                 (polygon-uvs sides)
                 (polygon-tris sides)))
  
  (defn new-go
    "returns a tuple of a new gameobject and its mesh" 
    [go-name] 
    (let [
          mesh (Mesh.)
          go (GameObject.)
          mf (cmpt+ go MeshFilter)
          mr (cmpt+ go MeshRenderer)
          ]
      (set! (.. go name) go-name)
      (set! (.. mf mesh) mesh)
      [go mesh]))
  
  (defn polygon 
    "returns a GameObject containing a unit polygon with n sides"
    ([sides]
     (let [[go mesh] (new-go (str "poly-" sides))]
       (generate-polygon-mesh mesh sides)
       go))
    ([go sides] 
     (generate-polygon-mesh (.. (cmpt go MeshFilter) mesh) sides)
     go))
  
  
  
      
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
    (let [[go mesh] (new-go (str "pent-" i))]
      (update-mesh mesh verts-v3 uvs tris)
      go))
  
  (defn add-vecs [[a1 b1 c1] [a2 b2 c2]] [(+ a1 a2) (+ b1 b2) (+ c1 c2)])
  (defn div-vec-scalar [v s] (map #(/ % s) v))
  
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
                     :go nil ;the gameobject to manipulate
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
  
  (def sphere (create-primitive :sphere))
  
  (defn on-sines [msg]
    (let [args (vec (.. msg (get_args)))
          [n freq amp] args]
      (when (= n 1)
        (set! (.. sphere transform position) 
              (v3 5 5 (* 0.1 freq)))
        )
      ))
  (.. osc-in (Map "/sines" #(on-sines %)))
  
  
  
      )







; TODO: sketch geometry for some spec types and functions
; (defnvr some-func "defines a fn and adds a geometric
; representation of it to the scene"
;  [args] (body))
; (def fnvrs (atom {"fn1" {:fn fn1 :go gameobj} ...}) )

; {:fn-vrs {"fn1" {:fn fn1 :go gameobject}}
;  :val-vrs {"val1" {:v 123 :go gameobject}}
;  :controls #{[:number-dial "val1"]}
;  :connections #{["val1" ["fn1" 0]]}}

; do this for vals (state) too. it all goes in one atom probably


; goal is to teach someone to program in a shared VR
; one shared camera position, a set of hands for each player
