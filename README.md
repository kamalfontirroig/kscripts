# kscripts
Kubectl scripts para no perder el tiempo copy-pasting. BCI times.

# Instalación
1) Descargar los scripts en la carpeta deseada.
   
2) Configurar su terminal preferido agregando a su archivo profile:
```
export KUBECTL_LOG_FOLDER='<ruta_carpeta_logs>'
alias klog='sh <ruta_carpeta_scripts>/kubectl_download_pod_log.sh'
alias ktail='sh <ruta_carpeta_scripts>/kubectl_load_tail_and_save_logs.sh'
alias kswitch='sh <ruta_carpeta_scripts>kubectl_switch_context_if_needed.sh'
alias krestart='sh <ruta_carpeta_scripts>/kubectl_restart_pod.sh'
```
`<ruta_carpeta_logs>` Carpeta donde quieres que se guarden los logs.

`<ruta_carpeta_scripts>` Carpeta donde se encuentran los scripts.

# Uso
`klog <"int"|"qa"> <nombre_completo_del_componente>`

`ktail <"int"|"qa"> <nombre_completo_del_componente>`

`kswitch <"int"|"qa">`

`krestart <"int"|"qa"> <nombre_completo_del_componente>`
