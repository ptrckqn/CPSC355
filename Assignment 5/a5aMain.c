//Patrick Quan - 10152770
//CPSC 355
//Assignment 5

#include <stdio.h>
#include <stdlib.h>

void enqueue (int value);
int dequeue();
int queueFull();
int queueEmpty();
void display();

int main(){
  int operation, value;

  do{
    system("clear");
    printf("### Queue Operations ### \n\n");
    printf("Press 1 - Enqueue, 2 - Dequeue, 3 - Display, 4 - Exit\n");
    printf("Your option? ");
    scanf("%d", &operation);

    switch(operation){
      case 1:
        printf("\nEnter positive interger value to be enqueued: ");
        scanf("%d", &value);
        enqueue(value);
        break;
      case 2:
        value = dequeue();
        if(value != -1){
          printf("\n Dequeue value is: %d\n", value);
        }
        break;
      case 3:
        display();
        break;
      case 4:
        printf("Terminating program\n");
        exit(0);
      default:
        printf("Invalid option! Try again.\n");
        break;
    }
    printf("\nPress the return key to continue . . . ");
    getchar();
    getchar();
  } while(operation != 4);

  return 0;
}
