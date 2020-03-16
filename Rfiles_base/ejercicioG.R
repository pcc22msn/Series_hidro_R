##Lectura de una cuenca hidrogr�fica en formato shape pol�gono
library(easypackages) 
library(sp)
library(rgdal)
library(raster)
library(lattice)
library(latticeExtra)
library(ncdf4)
# Definiendo un directorio de trabajo donde se encuentren los archivos input descargados
setwd("D:/2_Courses/R_Hidrologia/Tutorial_files") 
# Leyendo el pol�gono chillon.shp (layer: chillon) desde la carpeta "files" con data source name (dsn) 
cuenca.shape <- readOGR(dsn="shapes", layer="chillon")
# Conociendo el tipo de objeto despu�s de la importaci�n
class(cuenca.shape)
# Visualizando la cuenca con color cyan, se aprecia que se encuentra en coordenadas geograficas
plot(cuenca.shape, axes=T, col=c("red"))
# Conociendo el contenido del pol�gono importado
head(cuenca.shape@data)

######Proyecci�n y reproyecci�n de coordenadas
# Transformando a UTM zona 18, WGS84 y visualizando la conversi�n
cuenca.utm <- spTransform(cuenca.shape, CRS("+proj=utm +zone=18 +ellps=WGS84 +south +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"))
plot(cuenca.utm, axes=T, asp=1)
# Reproyectando a Geograficas WGS84 y visualizando la reconversi�n
cuenca.wgs <- spTransform(cuenca.utm, CRS("+proj=longlat +ellps=WGS84"))
plot(cuenca.wgs, axes=T, asp=1)


#####Lectura de la precipitaci�n espacializada desde un r�ster - M�todo 1
# Extrayendo datos y visualizando el producto r�ster PISCO 
r <- stack("PISCOV3-MONTHLY.nc") # El archivo *.nc debe estar en la carpeta lab2, no en subcarpetas
# Visualizando la precipitaci�n espacial del primer mes de 1981.
plot(r[[1]])
# Ploteando la cuenca del rio Chill�n dentro del mapa de precipitaciones
plot(cuenca.wgs, add=T)
# Delimitando el �rea de estudio al cuadrante que ocupa el rio Chill�n
r.chillon <- crop(r, cuenca.wgs, snap="out")
# Ploteando el primer mes de 1981 en el cuadrante que ocupa el rio Chill�n
plot(r.chillon[[1]])
# Delimitando el �rea de estudio a la cuenca del rio Chill�n
r.chillon <- mask(r.chillon, cuenca.wgs)
# Ploteando los meses de enero a diciembre de 1981
plot(r.chillon[[1:12]])
# Ploteando todos los meses del r�ster (431 datos) delimitado por la cuenca del rio Chill�n
spplot(r.chillon, col.regions = rev(terrain.colors(100)))

###Lectura de la precipitaci�n espacializada desde un r�ster - M�todo 2
# Extrayendo datos y visualizando
Pisco.prec.brick <- brick("PISCOV3-MONTHLY.nc") # El archivo *.nc debe estar en la carpeta lab2, no en subcarpetas
Pisco.prec.brick
nlayers(Pisco.prec.brick)
# Ploteando los primeros 12 meses de 1981 de la precipitaci�n para todo el Per�
plot(Pisco.prec.brick[[1:12]]) 
# Extrayendo los datos y promediando todas las grillas de la cuenca del Chill�n
pp.cuenca.mensual <- extract(Pisco.prec.brick, cuenca.wgs, fun=mean)
colnames(pp.cuenca.mensual) <- 1:ncol(pp.cuenca.mensual)
# Visualizando los 431 datos promediados 
View(pp.cuenca.mensual)
range(pp.cuenca.mensual)
# Ploteando la serie de los 431 valores de precipitaci�n mensual promedio areal
plot(pp.cuenca.mensual[1,], type="o", col="1", ylim=c(0,200), ylab="P (mm)", xlab = "Meses", main="Precipitacion promedio areal - Chillon (mm)")