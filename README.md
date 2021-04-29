# sonarqube-runner

### Alcance
El proyecto facilita el analisis de los productos de [QuadMinds](https://www.quadminds.com/)
 con la herramienta [Sonarqube](https://www.sonarqube.org/)

- QuadMinds flash
- QuadMinds Saas
- QuadMinds Events
- QuadMinds Stork
- QuadMinds Track & Trace

## Forma de uso

### Ver la ayuda
Muestra todos los comandos disponibles.

```
make 
make help
```

### Preparar el entorno para analizar los proyectos.
Descarga las imagenes de docker necesarias para levantar el servidor de sonarqube con la base de datos postgresql y el scanner para los proyectos.
Hay que ejecutarlo solo una vez.

Requiere permiso de sudoers para ejecutar los siguientes comandos que son requeidos por la imagen de sonar.
	@sudo sysctl -w vm.max_map_count=262144 
	@sudo sysctl -w fs.file-max=65536


```
make setup 
```


### Iniciar el servicio
```
make start 
```


### QuadMinds flash
Ejecuta el analisis del producto Flash.

```
make flash
```

### QuadMinds Saas
Ejecuta el analisis del producto Saas.

```
make saas
```

### QuadMinds Events
Ejecuta el analisis del producto QuadMinds Events.

```
make qm-events
```

### QuadMinds Stork
Ejecuta el analisis del producto Stork.

```
make stork
```

### QuadMinds Track & Trace
Ejecuta el analisis del producto Track & Trace.

```
make t_and_t
```
