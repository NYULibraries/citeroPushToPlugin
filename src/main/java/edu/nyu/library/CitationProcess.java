package edu.nyu.library;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.xmlbeans.XmlObject;

import com.exlibris.primo.infra.utils.FileTransferUtil;
import com.exlibris.primo.interfaces.PushToInterface;
import com.exlibris.primo.xsd.commonData.PrimoResult;

public class CitationProcess implements PushToInterface {
	private String dataURL;
	public String pushTo(HttpServletRequest request,
			HttpServletResponse response, PrimoResult[] record,
			boolean fromBasket) throws Exception {
		setDataURL(request,fromBasket);
		XmlObject rec = record[0].getSEGMENTS().getJAGROOTArray(0).getRESULT().getDOCSET().getDOCArray(0);
		StringWriter sw = new StringWriter();
		rec.save(sw);


		ServletOutputStream out = response.getOutputStream();
        response.setContentType("text/html");
        boolean service = false;
        String toFormat = "ris";
        String pushToService = request.getParameter("pushToType");
        if (pushToService.equals("RefWorks")){
            toFormat = "refworks";
            service = true;
        }
        if (pushToService.equals("EndNote")){
            toFormat = "endnote";
            service = true;
        }
        if (pushToService.equals("EasyBIB")){
            toFormat = "easybibpush";
            service = true;
	    }
        if (pushToService.equals("BibTeX"))
            toFormat = "bibtex";


        String citeroUrl = "http://web1.library.nyu.edu/export_citations/export_citations";
        String form = "<!DOCTYPE html>"
                +"<html>"
                +"<head>"
                +"  <title>Citero</title>"
                +"  <script type=\"text/javascript\">"
                +"      window.onload=function(){"
                +"          document.getElementById(\"submit\").click();"
                +"      }"
                +"  </script>"
                +"</head>"
                +"<body>"
                +"<div class=\"no_js\"><div class=\"inner_form_dialog\">"
                +"  <form id=\"\" action=\""+citeroUrl+"\" method=\"POST\" class=\"external_form\" enctype=\"application/x-www-form-urlencoded\">"
                +"      <h2>Push to "+ pushToService +"</h2>"
                +"      <div class=\"formError\">"
                +"      </div>"
                +"      <fieldset>"
                +"          <legend></legend>"
                +"          <textarea type=\"hidden\" name=\"from_format\" id=\"from_format\">PNX</textarea>"
                +"          <textarea type=\"hidden\" name=\"to_format\" id=\"to_format\">"+toFormat+"</textarea>"
                +"          <textarea name=\"data\" id=\"data\">"
                + sw.toString()
                +"          </textarea>"
                +"          <div class=\"section\">"
                +"              <input id=\"submit\" name=\"commit\" type=\"submit\" value=\"Push to "+ pushToService +"\" />"
                +"          </div>"
                +"      </fieldset>"
                +"  </form>"
                +"</div></div>"
                +"</body>"
                +"</html>";
        out.write(form.getBytes("UTF-8"));

		return null;
	}

	public String getContent(HttpServletRequest request, boolean fromBasket) {
		return null;
	}

	public String getFormAction() {
		return null;
	}

	private void setDataURL(HttpServletRequest request,boolean fromBasket) throws IOException{
		if (!fromBasket){
			dataURL = FileTransferUtil.getInetUrl(request)+
	        "/action/display.do?ct=display&doc="+request.getParameter("recId")
	        +"&showRIS=true&afterPDS=true&fromBasket="+fromBasket;
		}
		else{
			dataURL = FileTransferUtil.getInetUrl(request)+
	        "/action/display.do?showRIS=true&afterPDS=true&fromBasket="+fromBasket;
			for (int i=0; i < request.getParameterValues("docs").length; i++){
				dataURL = dataURL + "&docs=" + request.getParameterValues("docs")[i];
			}
		}
	}
}
