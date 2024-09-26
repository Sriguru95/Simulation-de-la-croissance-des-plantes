#include <string.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct csvString {
    char** values;
    int size;
    int* separations;
} csvString;





csvString* csv_tostring(char* filename){
char* csv_stream = NULL;
FILE* f = fopen(filename, "rb");
int filesize = 0;

csvString* res = malloc(sizeof(csvString));

if (f){
    fseek(f, 0, SEEK_END);
    filesize = ftell(f);
    fseek(f, 0, SEEK_SET);
    csv_stream = (char*) malloc(filesize + sizeof(char));
    //we know the filesize so we don't have to do a while reading loop
    int read_value = fread(csv_stream, 1, filesize, f);
    if (read_value == filesize){
        
        csv_stream[filesize] = '\0';     

        const char* const_comma = ",";
        const char* const_newline = "\n";

        char *str1, *str2, *token, *subtoken;
        char *saveptr1, *saveptr2;
        int i, j;
        int line_count = 0, val_count = 0;
        int* separations = (int*) malloc(sizeof(int));
        char **values = (char**) malloc(sizeof(char*));

        
        
        for (j = 0, str1 = csv_stream; ;j++, str1 = NULL) {
            
        token = strtok_r(str1, const_newline, &saveptr1);
        if (token == NULL)
            break;
        ++line_count;
        printf("%d: %s\n", j, token);
        separations = (int*) realloc(separations, line_count*sizeof(int));
        


        for (i = 0, str2 = token; ; i++, str2 = NULL) {
            subtoken = strtok_r(str2, const_comma, &saveptr2);
            if (subtoken == NULL)
                break;
            ++val_count;
            values = (char**) realloc(values, val_count*sizeof(char*)); 
            
            values[val_count-1] = subtoken;
            printf("	 -->%d: %s\n", val_count-1, values[val_count-1]);
        }
        separations[j] = val_count-1;
         
    }
    res->values = values;
    res->size =  val_count;
    res->separations = separations;
        



    }
   
}
 return res;

}



int main(int argc, char** argv){
	if (argc < 2) {
		printf("Usage: %s filename.csv\n", argv[0]);
		exit(1);
	}
    csvString* csv_struct = csv_tostring(argv[1]);


    int j = 0;
    int pos_cur = 0;
    int count_symbol = 0;
    int count_symbol_cur = 1;
    int offset_symbol = 0;
    char* out_name = malloc(strlen(argv[1]) + 5);
    strncpy(out_name, argv[1], strlen(argv[1]));
    strcat(out_name, ".xml");
    FILE* output = fopen(out_name, "w");
    fprintf(output, "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n<LSystems>\n");
    for (int i = 0; i < csv_struct->size; i++) {
        printf("%s, ", csv_struct->values[i]);
        if (pos_cur == 0){
        fprintf(output, "<LSys id=\"Lsys%d\">\n", j+1);
        fprintf(output, "<Name>%s</Name>\n", csv_struct->values[i]);
        
        }
        else if (pos_cur == 1){
            fprintf(output, "<Symbols id=\"Symbols%d\">\n", j+1);
            count_symbol_cur = strlen(csv_struct->values[i]);
            for (int k = 0; k < count_symbol_cur; k++){
                ++count_symbol;
                
                fprintf(output, "<Symbol id=\"Symbol%d\">%c</Symbol>\n",count_symbol,(csv_struct->values[i])[k]);
                
            }
            offset_symbol = count_symbol_cur;
            printf("offset_symbol: %d\n", offset_symbol);
            fprintf(output, "</Symbols>\n");

        }
        else if (pos_cur == 2){
            fprintf(output, "<Axiom>%s</Axiom>\n", csv_struct->values[i]);
        }
        else {
            int offset_backup = offset_symbol;
            
            fprintf(output, "<Substitutions id=\"Subst%d\">\n", j+1);
            for (int l = 0; l < count_symbol_cur; l++ ){
                
                fprintf(output, "<Substitution>\n<SymbolRef idref=\"Symbol%d\"/>\n", count_symbol-offset_symbol+1);
                fprintf(output, "<Image>%s</Image>\n</Substitution>", csv_struct->values[i]);
                --offset_symbol;
                ++i;

            }
            fprintf(output, "</Substitutions>\n");
            offset_symbol = offset_backup;
            fprintf(output, "<Interpretations id=\"Interp%d\">\n", j+1);
            for (int l = 0; l < count_symbol_cur; l++ ){
                fprintf(output, "<Interpretation>\n<SymbolRef idref=\"Symbol%d\"/>\n", count_symbol-offset_symbol+1);
                fprintf(output, "<Instruction>%s</Instruction>\n</Interpretation>", csv_struct->values[i]);
                --offset_symbol;
                ++i;

            }
            fprintf(output, "</Interpretations>\n");
            --i;
            
        }
        ++pos_cur;
        printf("i: %d, cond: %d\n", i, csv_struct->separations[j]);
        if (i == csv_struct->separations[j]) {
            fprintf(output, "</LSys>\n");
            ++j;
            pos_cur = 0;
        }
    }
    fprintf(output, "</LSystems>\n");




    return EXIT_SUCCESS;
}