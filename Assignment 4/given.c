#define FALSE 0
#define TRUE 1

struct point{
  int x, y; //4,4 = 8
};

struct dimension{
  int width, height; //4, 4 = 8
};

struct box{
  struct point origin; //8
  struct dimension size; //8
  int area; // 4
};

struct box newBox(){
  struct box b; //20

  b.origin.x = 0;
  b.origin.y = 0;
  b.size.width = 1;
  b.size.height= 1;
  b.area = b.size.width * b.size.height;

  return b;
}

void move(struct box *b, int deltaX, int deltaY){
  b -> origin.x += deltaX;
  b -> origin.y += deltaY;
}

void expand(struct box *b, int factor){
  b -> size.width *= factor;
  b -> size.height *= factor;
  b -> area = b -> size.width * b -> size.height;
}

void printBox(char *name, struct box *b){
  printf("Box %s origin = (%d, %d) width = %d height = %d area = %d\n", name,  b -> origin.x, b -> origin.y, b -> size.width, b -> size.height, b -> area);
}

int equal (struct box *b1, struct box *b2){
  int result = FALSE;

  if(b1 -> origin.x == b2 -> origin.x){
    if(b1 -> origin.y == b2 -> origin.y){
      if(b1 -> size.width == b2 -> size.width){
        if(b1 -> size.height == b2 -> size.height){
          result = TRUE;
        }
      }
    }
  }
  return result;
}

int main(){
  struct box first, second;

  first = newBox();
  second = newBox();

  printf("Initial box values: \n");
  printBox("first", &first);
  printBox("second", &second);

  if (equal(&first, &second)){
    move(&first, -5, 7);
    expand(&second, 3);
  }

  printf("\nChanged box values: \n");
  printBox("first", &first);
  printBox("second", &second);
}
