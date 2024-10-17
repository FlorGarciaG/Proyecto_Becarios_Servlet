<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.Cookie" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro de Vivienda</title>
    </head>
    <body>
        <button><a href="${pageContext.request.contextPath}/views/bienvenida.jsp" style="text-decoration: none; color: inherit;">Regresar</a></button>

        <h1>Alta de Vivienda</h1>

        <%
            // Obtener la cookie de la CURP
            Cookie[] cookies = request.getCookies();
            String curp = "";
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("curp".equals(cookie.getName())) {
                        curp = cookie.getValue();
                        break;
                    }
                }
            }
        %>

        <form action="${pageContext.request.contextPath}/vivienda_servlet" method="POST">
            CURP del becario:
            <input type="text" id="curp" name="curp" value="<%= curp%>" readonly><br>
            Calle:
            <input type="text" id="calle" name="calle" required><br>

            Colonia:
            <input type="text" id="colonia" name="colonia" required><br>

            Municipio:
            <input type="text" id="municipio" name="municipio" required><br>

            Código Postal:
            <input type="number" step="0" id="cp" name="cp" maxlength="10" required><br>
            <br>


            <input type="submit" name="accion" value="Registrar">
        </form>


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
    </body>
</html>
