# NETHIVE NEO - Contexto del Proyecto

## 📋 Resumen General

**NETHIVE NEO** es una aplicación Flutter para la gestión de infraestructura de red MDF/IDF (Main Distribution Frame / Intermediate Distribution Frame). La aplicación permite administrar empresas, negocios y componentes de red de forma integral con una interfaz moderna y responsiva.

## 🎯 Objetivo Principal

Crear un sistema completo de gestión de infraestructura de telecomunicaciones que permita:
- Administrar múltiples empresas y sus negocios
- Gestionar inventario de componentes de red (switches, patch panels, cables, etc.)
- Monitorear el estado y uso de la infraestructura
- Proporcionar dashboards informativos
- Ofrecer una experiencia optimizada tanto para escritorio como móvil

## 🏗️ Arquitectura del Proyecto

### **Backend & Base de Datos**
- **Supabase** como backend principal
- Schema `nethive` para datos específicos del dominio
- Autenticación y autorización integrada
- Realtime para actualizaciones en tiempo real

### **Frontend - Flutter**
- **Material Design** con tema personalizado
- **Provider** para gestión de estado
- **Go Router** para navegación
- **PlutoGrid** para tablas de datos
- **Responsive Design** adaptativo

### **Estructura de Navegación**
```
Login → Empresas/Negocios → Infraestructura MDF/IDF
                              ├── Dashboard
                              ├── Inventario
                              ├── Topología
                              ├── Alertas
                              └── Configuración
```

## 📱 Funcionalidades Implementadas

### **1. Gestión de Empresas y Negocios**
- **Vista de escritorio**: Sidebar con empresas + tabla PlutoGrid de negocios
- **Vista móvil**: Cards responsivas con información completa
- **Funciones**: Crear, editar, eliminar empresas y negocios
- **Navegación**: Botón prominente "Acceder a Infraestructura" en cada negocio

### **2. Layout de Infraestructura**
- **Sidemenu responsivo** con módulos:
  - Dashboard (métricas y estadísticas)
  - Inventario (gestión de componentes)
  - Topología (visualización de red)
  - Alertas (notificaciones del sistema)
  - Configuración (parámetros del sistema)
- **Header dinámico** con breadcrumb: Empresa > Negocio > Módulo
- **Navegación móvil** con drawer colapsible

### **3. Dashboard MDF/IDF**
- **Vista de escritorio**: Cards de estadísticas, gráficos, alertas recientes
- **Vista móvil**: Layout optimizado con cards compactas y información escalonada
- **Métricas**: Componentes totales, activos, en uso, categorías
- **Actividad**: Feed de eventos recientes del sistema

### **4. Inventario de Componentes**
- **Vista de escritorio**: Tabla PlutoGrid con filtros y paginación
- **Vista móvil**: Cards interactivas con detalles completos
- **Gestión**: CRUD completo de componentes de red
- **Categorización**: Switches, patch panels, cables, etc.
- **Estados**: Activo/Inactivo, En uso/Libre

## 🎨 Diseño y UX

### **Tema Visual**
- **Colores primarios**: Verdes esmeralda (#10B981) con gradientes modernos
- **Colores secundarios**: Azules de acento (#3B82F6) para contrastes
- **Fondo**: Esquema oscuro moderno (#0F172A, #1E293B, #334155)
- **Tipografía**: Google Fonts Poppins con jerarquía clara
- **Iconografía**: Material Icons con iconos personalizados
- **Animaciones**: Transiciones fluidas y feedback visual

### **Responsividad**
- **Móvil (≤800px)**: Vista de cards, menú hamburguesa, modals deslizables
- **Tablet (801-1200px)**: Tabla compacta, sidemenu colapsible
- **Escritorio (>1200px)**: Vista completa con todas las funcionalidades

### **Componentes Clave**
- **Cards animadas** con hover effects y entrada escalonada
- **Gradientes modernos** en headers y botones
- **Estados visuales** claros con colores semánticos
- **Modals interactivos** para detalles y formularios
- **Breadcrumbs dinámicos** para navegación contextual

## 📊 Providers (Gestión de Estado)

### **NavigationProvider**
- Maneja el negocio seleccionado
- Controla la navegación entre módulos del sidemenu
- Mantiene el contexto de empresa/negocio activo

### **EmpresasNegociosProvider**
- CRUD de empresas y negocios
- Estados de PlutoGrid para tablas
- Filtros y búsquedas
- Manejo de archivos (logos e imágenes)
- Integración con Supabase Storage

### **ComponentesProvider**
- Gestión completa del inventario MDF/IDF
- Categorías de componentes dinámicas
- Estados de componentes (activo, en uso, ubicación)
- Detalles específicos por tipo de componente
- Búsquedas y filtros avanzados

## 🔄 Flujo de Usuario Actual

1. **Login** → Autenticación con Supabase
2. **Selección de Empresa** → Vista de empresas con negocios asociados
3. **Acceso a Infraestructura** → Click en botón de cualquier negocio
4. **Layout Principal** → Sidemenu con módulos + header con breadcrumb
5. **Navegación entre Módulos** → Dashboard, Inventario, etc.
6. **Vista Adaptativa** → Escritorio (tablas) vs Móvil (cards)

## 🚀 Características Técnicas

### **Dependencias Principales**
```yaml
flutter: SDK
provider: ^6.0.5          # Gestión de estado
go_router: ^12.0.0        # Navegación
supabase_flutter: ^2.0.0  # Backend
pluto_grid: ^7.0.0        # Tablas de datos
google_fonts: ^6.0.0      # Tipografías
file_picker: ^6.0.0       # Selección de archivos
```

### **Estructura de Archivos**
```
lib/
├── main.dart                    # Entry point con providers
├── router/router.dart           # Configuración de rutas
├── theme/theme.dart            # Tema y estilos globales
├── providers/nethive/          # Providers específicos del dominio
│   ├── empresas_negocios_provider.dart
│   ├── componentes_provider.dart
│   └── navigation_provider.dart
├── pages/
│   ├── empresa_negocios/       # Gestión empresarial
│   │   ├── empresa_negocios_page.dart
│   │   └── widgets/           # Widgets especializados
│   └── infrastructure/         # Módulos MDF/IDF
│       ├── pages/             # Páginas principales
│       └── widgets/           # Componentes reutilizables
├── models/nethive/             # Modelos de datos
└── helpers/                    # Utilidades y constantes
```

## 🎯 Estado Actual del Desarrollo

### **✅ Completado**
- ✅ Sistema de autenticación con Supabase
- ✅ Gestión completa de empresas y negocios (escritorio + móvil)
- ✅ Layout de infraestructura con sidemenu responsivo
- ✅ Dashboard con métricas y estadísticas (escritorio + móvil)
- ✅ Inventario con tabla PlutoGrid y vista de cards móvil
- ✅ Navegación completa entre módulos con breadcrumbs
- ✅ Tema visual moderno y completamente responsivo
- ✅ Animaciones y transiciones fluidas
- ✅ Manejo de archivos e imágenes con Supabase Storage

### **🔄 En Desarrollo**
- 🔄 Módulo de Topología de red
- 🔄 Sistema de Alertas en tiempo real
- 🔄 Configuración avanzada del sistema
- 🔄 Formularios de creación/edición de componentes

### **📋 Próximas Funcionalidades**
- 📋 Reportes y exportación de datos
- 📋 Gestión de usuarios y permisos
- 📋 Integración con APIs de equipos de red
- 📋 Monitoreo en tiempo real de componentes
- 📋 Mapas interactivos para ubicaciones
- 📋 Módulo de mantenimiento preventivo

## 🎨 Filosofía de Diseño

**NETHIVE NEO** sigue los principios de **Material Design 3** con personalización corporativa, priorizando:
- **Usabilidad** por encima de la complejidad
- **Responsividad** real (no solo adaptativa)
- **Consistencia visual** en todos los módulos
- **Feedback inmediato** en todas las interacciones
- **Accesibilidad** para diferentes tipos de usuarios
- **Performance** optimizada con animaciones 60fps

## 🔧 Configuración de Base de Datos

### **Esquema Principal: `nethive`**
```sql
-- Tablas principales
empresa                    # Gestión de empresas
negocio                   # Sucursales/ubicaciones
categoria_componente      # Tipos de componentes
componente               # Inventario principal

-- Tablas de detalles específicos
detalle_cable
detalle_switch
detalle_patch_panel
detalle_rack
detalle_organizador
detalle_ups
detalle_router_firewall
detalle_equipo_activo
```

### **Storage Buckets**
```
nethive/
├── logos/              # Logos de empresas y negocios
├── imagenes/           # Imágenes generales
└── componentes/        # Imágenes de componentes
```

## 📝 Patrones de Desarrollo

### **Estado y Navegación**
- **Provider Pattern** para gestión de estado
- **Go Router** para navegación declarativa
- **Consumer Widgets** para reactividad
- **AnimationController** para transiciones

### **Responsividad**
- **MediaQuery** para breakpoints
- **LayoutBuilder** para adaptación dinámica
- **Flexible/Expanded** para layouts fluidos
- **Custom Widgets** para cada viewport

### **Arquitectura de Datos**
- **Repository Pattern** implícito en providers
- **Model Classes** con factory constructors
- **JSON Serialization** manual optimizada
- **Error Handling** robusto con try-catch

## 🚀 Guías de Extensión

### **Añadir Nuevo Módulo**
1. Crear provider en `providers/nethive/`
2. Añadir modelos en `models/nethive/`
3. Crear páginas en `pages/infrastructure/pages/`
4. Registrar en `navigation_provider.dart`
5. Añadir ruta en router

### **Añadir Vista Móvil**
1. Detectar viewport con `MediaQuery`
2. Crear widget específico en `widgets/`
3. Implementar cards con animaciones
4. Añadir modals para detalles
5. Testear en diferentes dispositivos

Este contexto debe servir como referencia para mantener la coherencia del proyecto en futuras iteraciones y para que nuevos desarrolladores comprendan rápidamente la estructura y objetivos del sistema.

---
**Fecha de creación**: 20 de julio de 2025  
**Versión**: 1.0  
**Proyecto**: NETHIVE NEO - Sistema de Gestión de Infraestructura MDF/IDF