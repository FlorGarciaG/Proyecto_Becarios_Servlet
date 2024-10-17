<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.Cookie" %>
<%@ page import="Configuration.ConnectionBD" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Ver más detalles</title>
    </head>
    <body>

        <%
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
            String nombre = "Invitado";
            String apellidoP = "";
            String apellidoM = "";
            String genero = "";
            Date fechaNacimiento = null;
            String imagePath = "default.jpg"; // Imagen por defecto

            // Variables para los datos de vivienda
            String calle = "";
            String colonia = "";
            String municipio = "";
            String cp = "";

            if (curp != null) {
                // Realizar la consulta para obtener los datos del becario y vivienda
                Connection conn = null;
                PreparedStatement psBecario = null;
                PreparedStatement psVivienda = null;
                ResultSet rsBecario = null;
                ResultSet rsVivienda = null;

                try {
                    ConnectionBD conexion = new ConnectionBD();
                    conn = conexion.getConnectionBD();

                    // Consulta para obtener datos del becario
                    String sqlBecario = "SELECT * FROM becario WHERE curp = ?";
                    psBecario = conn.prepareStatement(sqlBecario);
                    psBecario.setString(1, curp);
                    rsBecario = psBecario.executeQuery();

                    if (rsBecario.next()) {
                        nombre = rsBecario.getString("nombre");
                        apellidoP = rsBecario.getString("apellidoP");
                        apellidoM = rsBecario.getString("apellidoM");
                        genero = rsBecario.getString("genero");
                        fechaNacimiento = rsBecario.getDate("fecha_nac");
                        imagePath = rsBecario.getString("foto") != null ? rsBecario.getString("foto") : "default.jpg"; // Imagen
                    }

                    // Consulta para obtener datos de vivienda
                    String sqlVivienda = "SELECT * FROM vivienda WHERE curp = ?";
                    psVivienda = conn.prepareStatement(sqlVivienda);
                    psVivienda.setString(1, curp);
                    rsVivienda = psVivienda.executeQuery();

                    if (rsVivienda.next()) {
                        calle = rsVivienda.getString("calle");
                        colonia = rsVivienda.getString("colonia");
                        municipio = rsVivienda.getString("municipio");
                        cp = rsVivienda.getString("cp");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    if (rsBecario != null) try {
                        rsBecario.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    if (psBecario != null) try {
                        psBecario.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    if (rsVivienda != null) try {
                        rsVivienda.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    if (psVivienda != null) try {
                        psVivienda.close();
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
        <button><a href="${pageContext.request.contextPath}/views/bienvenida.jsp" style="text-decoration: none; color: inherit;">Regresar</a></button>

        <!-- Mostrar el nombre del becario -->
        <h1>Detalles de <%= nombre%>!</h1>

        <!-- Mostrar imagen del becario -->
        <div class="image-container">            
            <img src="<%= request.getContextPath() + "/" + imagePath%>" alt="Foto" height="150px">

            <form action="${pageContext.request.contextPath}/imagen_servlet" method="POST" enctype="multipart/form-data">
                <input type="file" name="image" id="image">
                <button type="submit">Actualizar Imagen</button>
            </form>
        </div>
        <br>

        <!-- Tabla con la información del becario -->
        <h2>Información del Becario</h2>
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

        <!-- Tabla con la información de la vivienda -->
        <h2>Información de Vivienda</h2>
        <table border="1">
            <tr>
                <th>Calle</th>
                <td><%= calle%></td>
            </tr>
            <tr>
                <th>Colonia</th>
                <td><%= colonia%></td>
            </tr>
            <tr>
                <th>Municipio</th>
                <td><%= municipio%></td>
            </tr>
            <tr>
                <th>Código Postal</th>
                <td><%= cp%></td>
            </tr>
        </table>

        <br>

    </body>
</html>
