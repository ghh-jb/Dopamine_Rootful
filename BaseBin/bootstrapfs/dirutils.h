kern_return_t ensure_directory_exists(const char *path);
bool dir_exists_and_nonempty(const char *dir);
kern_return_t copy_dir_recursive(const char *src, const char *dst);
void debug(char *format, ...);
char* jbrootpath();
char* getItemInJBROOT(char* item);
int (*jbclient_root_steal_ucred)(uint64_t ucredToSteal, uint64_t *origUcred);