<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.Cookie" %>
<%@ page import="Configuration.ConnectionBD" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Página de Bienvenida</title>
        <style>
            .image-container {
                display: flex;
                align-items: center;
            }
            .image-container img {
                max-width: 150px;
                margin-right: 10px;
            }
        </style>
    </head>
    <body>

        <%
            // Obtener la sesión actual
            HttpSession session_web = request.getSession(false);
            // No crear una nueva sesión si no existe
            String curp2 = null;
            if (session_web != null) {
                curp2 = (String) session_web.getAttribute("curp");
            }

            // Obtener la duración de la sesión en minutos (desde web.xml o configuración)
            int sessionTimeout = session_web.getMaxInactiveInterval(); // Tiempo en segundos
            int remainingTime = sessionTimeout; // Lo convertimos en segundos para usarlo en el temporizador
            // Obtener la cookie de la curp
            Cookie[] cookies = request.getCookies();
            String curp = null;
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("curp".equals(cookie.getName())) {
                        curp = cookie.getValue();
                        break;
                    }
                }
            }

            // Variables para los datos del becario
            String nombre = "Iniciar sesión"; // Mostrar "Iniciar sesión" si no hay cookie
            String apellidoP = "";
            String apellidoM = "";
            String genero = "";
            Date fechaNacimiento = null;
            String imagePath = null; // Imagen por defecto

            if (curp != null) {
                // Realizar la consulta para obtener los datos del becario
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;

                try {
                    ConnectionBD conexion = new ConnectionBD();
                    conn = conexion.getConnectionBD();
                    String sql = "SELECT * FROM becario WHERE curp = ?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, curp);
                    rs = ps.executeQuery();

                    if (rs.next()) {
                        nombre = rs.getString("nombre");
                        apellidoP = rs.getString("apellidoP");
                        apellidoM = rs.getString("apellidoM");
                        genero = rs.getString("genero");
                        fechaNacimiento = rs.getDate("fecha_nac");
                        imagePath = rs.getString("foto") != null ? rs.getString("foto") : null; // Imagen
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) try {
                        rs.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    if (ps != null) try {
                        ps.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    if (conn != null) try {
                        conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        %>

        <h1>
            <% if (curp == null) { %>
            No has iniciado sesión <br>
            <button><a href="${pageContext.request.contextPath}/views/login.jsp" style="text-decoration: none; color: inherit;">Iniciar sesión</a></button>
            <% } else {%>            
            Bienvenid@ <%= nombre%>!
            <% } %>
        </h1>
        <div id="timer">00:00</div><br>
        <% if (curp != null) {%>
        <div class="image-container">            
            <img src="<%= request.getContextPath() + "/" + imagePath%>" alt="Foto" height="150px">

            <form action="${pageContext.request.contextPath}/imagen_servlet" method="POST" enctype="multipart/form-data">
                <input type="file" name="image" id="image">
                <button type="submit">Actualizar Imagen</button>
            </form>
        </div>

        <br>

        <button><a href="${pageContext.request.contextPath}/views/registro_vivienda.jsp" 
                   style="text-decoration: none; color: inherit;">Registrar vivienda</a></button>
        <br><br>

        <table border="1">
            <tr>
                <th>CURP</th>
                <td><%= curp%></td>
            </tr>
            <tr>
                <th>Nombre</th>
                <td><%= nombre%></td>
            </tr>
            <tr>
                <th>Apellido Paterno</th>
                <td><%= apellidoP%></td>
            </tr>
            <tr>
                <th>Apellido Materno</th>
                <td><%= apellidoM%></td>
            </tr>
            <tr>
                <th>Fecha de Nacimiento</th>
                <td><%= fechaNacimiento != null ? fechaNacimiento.toString() : "N/D"%></td>
            </tr>
            <tr>
                <th>Género</th>
                <td><%= genero%></td>
            </tr>
        </table>
        <br>
        <button><a href="${pageContext.request.contextPath}/views/detalles_becario.jsp" style="text-decoration: none; color: inherit;">Ver detalles</a></button>

        <br><br>
        <a href="${pageContext.request.contextPath}/login_servlet">Cerrar Sesion</a>

        <% } %>

        <%
            // Mostrar mensaje de éxito o error si existe
            String mensaje = (String) request.getAttribute("mensaje");
            if (mensaje != null) {
        %>
        <script>
            alert("<%= mensaje%>");
        </script>
        <%
            }
        %>

        <script>
            let remainingTime = <%= remainingTime%>; // Tiempo en segundos desde el servidor

            // Función para verificar si la cookie 'curp' existe
            function checkCookie() {
                const curpCookie = document.cookie.split('; ').find(row => row.startsWith('curp='));
                if (!curpCookie) {
                    // Si la cookie 'curp' no existe, eliminarla por si acaso y redirigir al login
                    document.cookie = "curp=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
                    alert("Su sesión ha expirado. Será redirigido al login.");
                    window.location.href = '<%= request.getContextPath()%>/jsp/login.jsp'; // Redirige al login
                }
            }

            // Función para iniciar el temporizador
            function startTimer() {
                const timerElement = document.getElementById('timer');
                const interval = setInterval(function () {
                    let minutes = Math.floor(remainingTime / 60);
                    let seconds = remainingTime % 60;

                    // Formatear los números para que siempre tengan 2 dígitos
                    minutes = minutes < 10 ? '0' + minutes : minutes;
                    seconds = seconds < 10 ? '0' + seconds : seconds;

                    // Mostrar el tiempo restante en el elemento HTML
                    timerElement.textContent = minutes + ":" + seconds;

                    // Reducir el tiempo en 1 segundo
                    if (--remainingTime < 0) {
                        clearInterval(interval);
                        // Borrar la cookie por completo
                        document.cookie = "curp=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
                        alert("Tu sesión ha expirado. Serás redirigido a la página de login.");
                        window.location.href = '<%= request.getContextPath()%>/jsp/login.jsp'; // Redirige al login
                    }
                }, 1000); // Actualiza cada segundo

                // Restablecer el temporizador al detectar actividad
                function resetTimer() {
                    remainingTime = <%= sessionTimeout%>; // Restablecer a la duración original de la sesión
                }

                // Detectar actividad del usuario
                window.addEventListener('mousemove', resetTimer);
                window.addEventListener('keydown', resetTimer);
                window.addEventListener('click', resetTimer);
            }

            // Verificar la cookie al cargar la página
            window.onload = function () {
                checkCookie();  // Verifica si la cookie existe
                startTimer();   // Inicia el temporizador
            };
        </script>


    </body>
</html>
