// Maze generator
// A* algorithm finding the shortest way between two points 
// It is possible to click on new points.
// By Jaroslav Trnka, 2020
// https://github.com/JaroslavTrnka1
// jaroslav_trnka@centrum.cz

int xside;
int yside;
int actualposition;
int start, target;
int direction;
ArrayList <Integer> tovisit = new ArrayList<Integer> ();
ArrayList <Integer> topath = new ArrayList<Integer> ();
ArrayList <Integer> pathfront = new ArrayList <Integer> ();
ArrayList <Integer> futurepathfront = new ArrayList <Integer> ();
ArrayList <Integer> track = new ArrayList<Integer> ();
ArrayList <Integer> trackback = new ArrayList<Integer> ();
ArrayList <cell> field = new ArrayList <cell> ();
boolean destroyed;
boolean pathfinished;
int numdestroy;

void setup() {
  size(800,800);
  actualposition = 0;
  direction = 1;
  start = 0;
  destroyed = false;
  pathfinished = false;
  numdestroy = 50;
  xside = 20;
  yside = 20;
  target = yside * xside - 1;
  for (int i = 1; i < (yside * xside); i++) {tovisit.add(i);}
  for (int k = 0; k < (yside * xside); k++) {topath.add(k);}
  for (int j = 0; j < (yside * xside); j++) {field.add(new cell(j));}
  track.add(0);
}

void draw () {
 background(255);
 if (tovisit.size() == 0) {
   if (!destroyed) {
     destroy();
     path();
   }
   if (!pathfinished) {
   path();
   }
 }
 else {
   field.get(actualposition).move();
   fill(200,0,0);
   ellipse((width/xside)*(0.5 + field.get(actualposition).pos.x), (height/yside)*(0.5 + field.get(actualposition).pos.y), 5, 5);
 }
 for (cell c : field) {
  c.celldraw(); 
 }
}

void path() {
  trackback = new ArrayList<Integer> ();
  futurepathfront = new ArrayList <Integer> ();
  pathfront = new ArrayList <Integer> ();
  pathfront.add(start);
  while (!pathfront.contains(target)){
    for (int p : pathfront) {
      for (int e : field.get(p).exits) {
        if (topath.contains(e)) {
          futurepathfront.add(e);
          field.get(e).fastestpath = p;
          topath.remove(topath.indexOf(e));
        }
      }
    }
    pathfront = futurepathfront;
    futurepathfront = new ArrayList <Integer> ();
  }
  
  trackback.add(target);
  int last = target;
  while (!trackback.contains(start)) {
    trackback.add(field.get(last).fastestpath);
    last = field.get(last).fastestpath;
  }
  pathfinished = true;
}

void mousePressed (){
  if (destroyed) {
    if (direction == 1) {target = xside * int(mouseY/(height/yside)) + int(mouseX/(width/xside));}
    else {start = xside * int(mouseY/(height/yside)) + int(mouseX/(width/xside));}
    direction = direction * -1;
    pathfinished = false;
    topath = new ArrayList();
    for (int k = 0; k < (yside * xside); k++) {topath.add(k);}
  }
}

void destroy() {
   for (int i  = 0; i < numdestroy; i++) {
     int d = int(random(field.size() - xside));
     int r = xside * int(random(yside)) + int(random(xside-1));
     if (field.get(d).downwall == true) {
       field.get(d).downwall = false;
       field.get(d).exits.add(d + xside);
       field.get(d + xside).exits.add(d);
     }
     if (field.get(r).rightwall == true) {
       field.get(r).rightwall = false;
       field.get(r).exits.add(r + 1);
       field.get(r + 1).exits.add(r);
     }     
   }
   destroyed = true;
}

class cell{
 ArrayList <Integer> neighbours;
 ArrayList <Integer> exits;
 int fastestpath;
 boolean rightwall;
 boolean downwall;
 PVector pos;
 int id;
 
 cell(int index) {
   exits = new ArrayList<Integer> ();
   neighbours = new ArrayList<Integer> ();
   rightwall = true;
   downwall = true;
    if (index >= xside) {neighbours.add(index - xside);}
    if (index < (yside-1) * xside) {neighbours.add(index + xside);}
    if ((index % xside) > 0) {neighbours.add(index - 1);}
    if ((index % xside) < yside-1) {neighbours.add(index + 1);}
   pos = new PVector(index % xside, int (index / xside));
   id = index;
 }
 
  void move() {
    neighbours.retainAll(tovisit);
    if (neighbours.isEmpty()) {
      deadend();
    }
    else {
      int step = neighbours.get(int(random(neighbours.size())));
      track.add(step);
      tovisit.remove(tovisit.indexOf(step));
      exits.add(step);
      field.get(step).exits.add(actualposition);
      if (step - actualposition == 1) {rightwall = false;}
      if (step - actualposition == -1) {field.get(step).rightwall = false;}
      if (step - actualposition == yside) {downwall = false;}
      if (step - actualposition == -yside) {field.get(step).downwall = false;}
      actualposition = step;
    }
 }

 void celldraw() {
   strokeWeight(1);
   if (rightwall) {line((pos.x+1) * (width/xside), pos.y * (height/yside), (pos.x+1) * (width/xside), (pos.y + 1) * (height/yside));}
   if (downwall) {line((pos.x) * (width/xside), (pos.y+1) * (height/yside), (pos.x+1) * (width/xside), (pos.y + 1) * (height/yside));}
   if (trackback.contains(id)) {
     strokeWeight(3);
     fill(0,0,250);
     //ellipse((width/xside)*(0.5 + pos.x), (height/yside)*(0.5 + pos.y), 5, 5);
     line((width/xside)*(0.5 + pos.x), (height/yside)*(0.5 + pos.y), (width/xside)*(0.5 + field.get(trackback.get(constrain(-1+trackback.indexOf(id), 0,trackback.size()-1))).pos.x), (height/yside)*(0.5 + field.get(trackback.get(constrain(-1+trackback.indexOf(id), 0,trackback.size()-1))).pos.y));     
   }
   if ((id == start) || (id == target)) {
     fill(0,0,250);
     ellipse((width/xside)*(0.5 + pos.x), (height/yside)*(0.5 + pos.y), 8, 8);
   }
 }
 
 void deadend() {
  actualposition = track.get(track.size()-2); 
  track.remove(track.size()-1); 
 }
}
