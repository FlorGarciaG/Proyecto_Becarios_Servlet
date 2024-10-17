/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller;

import Configuration.ConnectionBD;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

/**
 *
 * @author florc
 */
@WebServlet(name = "imagen_servlet", urlPatterns = {"/imagen_servlet"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10 MB
        maxRequestSize = 1024 * 1024 * 50)
public class imagen_servlet extends HttpServlet {

    private static final String UPLOAD_DIR = "images";
    Connection conn;
    PreparedStatement ps;

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try ( PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet imagen_servlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet imagen_servlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Obtener la CURP de la cookie
        String curp = null;
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("curp".equals(cookie.getName())) {
                    curp = cookie.getValue();
                    break;
                }
            }
        }

        if (curp == null) {
            response.getWriter().println("No se encontró la CURP en las cookies.");
            return;
        }

        //obtener la ruta absoluta de la carpeta images
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;

        //Crear la carpeta images si no existe
        File uploadDir = new File(uploadFilePath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        //Obtener la imagen subida
        Part part = request.getPart("image");
        String fileName = getFileName(part);

        //Guardar la imagen en el servidor (en la carpeta "images")
        String filePath = uploadFilePath + File.separator + fileName;
        part.write(filePath);

        String relativePath = UPLOAD_DIR + File.separator + fileName;
        System.out.println("Path: " + relativePath);

        // Guardar la ruta de la imagen en la base de datos
        boolean isSaved = saveImagePathToDatabase(curp, relativePath);

        // Redirigir a la página de bienvenida
        if (isSaved) {
            response.sendRedirect(request.getContextPath() + "/views/bienvenida.jsp");
        } else {
            response.getWriter().println("Error al guardar la imagen en la base de datos.");
        }
    }

    //  Método para obtener el nombre del archivo obtenido
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 2, token.length() - 1);
            }
        }
        return "";
    }

    private boolean saveImagePathToDatabase(String curp, String imagePath) {
        try {
            ConnectionBD conexion = new ConnectionBD();
            conn = conexion.getConnectionBD();
            String sql = "UPDATE becario SET foto = ? WHERE curp = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, imagePath);
            ps.setString(2, curp);

            int filasActualizadas = ps.executeUpdate();
            if (filasActualizadas > 0) {
                System.out.println("Imagen actualizada correctamente en la base de datos.");
            } else {
                System.out.println("No se encontró el becario con la CURP proporcionada.");
            }

            ps.close();
            conn.close();
            return filasActualizadas > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
