##!/usr/bin/python3.8
# -*- coding: utf-8 -*-
"""
Created on Sun Oct 10 21:43:24 2021
@author: Alicia Gómez González
"""
# PreviewFCS
def PreviewFCS_function (FCSfile, FCSfile_path): 
    import gp #Cargamos el paquete de gene-pattern
    
   
    gpserver = gp.GPServer("https://cloud.genepattern.org/gp", "aligogon", "cytometry2021") #nos conectamos al servidor de genepattern
    
    #Accedemos al módulo
    #previewfcs_task = gp.GPTask(gpserver, "urn:lsid:broad.mit.edu:cancer.software.genepattern.module.analysis:00185:2")
    previewfcs_task = gp.GPTask(gpserver, "PreviewFCS")
    
    # Load the parameters from the GenePattern server ->sin esto no funcionaría
    previewfcs_task.param_load()
    
    # Create a JobSpec object for launching a job 
    previewfcs_job_spec = previewfcs_task.make_job_spec()
    
        
    uploaded_file = gpserver.upload_file(FCSfile, FCSfile_path)  # Upload the input file
   
    
    previewfcs_job_spec.set_parameter("Input.FCS.data.file", uploaded_file.get_url())
    previewfcs_job_spec.set_parameter("Output.file.format", "HTML")
    previewfcs_job_spec.set_parameter("Output.file.name", "<Input.FCS.data.file_basename>")
    #
    previewfcs_job = gpserver.run_job(previewfcs_job_spec)
    output_list=previewfcs_job.get_output_files()
    for file in output_list:
        #print(file.get_url()) #comprobación
        data="https://aligogon:cytometry2021@cloud.genepattern.org/gp/rest/v1/jobs/" + str(previewfcs_job.job_number) + "/download" #crei esto para que la función me genere un link con la descarga de los archivos analizados
    return (data)

# FcsToCsv 
def FcsToCsv_function (FCSfile, FCSfile_path): 
    import gp #Cargamos el paquete de gene-pattern
    
    
    gpserver = gp.GPServer("https://cloud.genepattern.org/gp", "aligogon", "cytometry2021") #nos conectamos al servidor de genepattern
    
    #Accedemos al módulo
    
    fcstocsv_task = gp.GPTask(gpserver, "FcsToCsv")
    
    # Load the parameters from the GenePattern server ->sin esto no funcionaría
    fcstocsv_task.param_load()
    
    # Create a JobSpec object for launching a job 
    fcstocsv_job_spec = fcstocsv_task.make_job_spec()
    
        
    uploaded_file = gpserver.upload_file(FCSfile, FCSfile_path)  
    

    
    fcstocsv_job_spec.set_parameter("Input.FCS.data.file", uploaded_file.get_url())
    fcstocsv_job_spec.set_parameter("Output.CSV.file.name", "<Input.FCS.data.file_basename>.csv")
    fcstocsv_job_spec.set_parameter("Use.full.names", "TRUE")
    fcstocsv_job_spec.set_parameter("Output.keywords.file.name", "<Input.FCS.data.file_basename>")
    fcstocsv_job_spec.set_parameter("Output.keywords.mode", "CSV")
    fcstocsv_job_spec.set_parameter("Channel.to.scale.conversion", "TRUE")
    fcstocsv_job_spec.set_parameter("Precision", "FALSE")
    fcstocsv_job_spec.set_parameter("Output.file.name", "<Input.FCS.data.file_basename>")
    
    
    #
    fcstocsv_job = gpserver.run_job(fcstocsv_job_spec)
    output_list=fcstocsv_job.get_output_files()
    for file in output_list:
       # print(file.get_url()) 
       data="https://aligogon:cytometry2021@cloud.genepattern.org/gp/rest/v1/jobs/" + str(fcstocsv_job.job_number) + "/download"
    #haciendo eso se bajaría un zip con ambos archivos
    return (data)

# CcsToFsv 
def CsvToFcs_function (CSVfile, CSVfile_path): 
    import gp #Cargamos el paquete de gene-pattern
    
    
    gpserver = gp.GPServer("https://cloud.genepattern.org/gp", "aligogon", "cytometry2021") #nos conectamos al servidor de genepattern
    
    #Accedemos al módulo
    
    csvtofcs_task = gp.GPTask(gpserver, "CsvToFcs")
    
    # Load the parameters from the GenePattern server ->sin esto no funcionaría
    csvtofcs_task.param_load()
    
    # Create a JobSpec object for launching a job 
    csvtofcs_job_spec = csvtofcs_task.make_job_spec()
    
        
    uploaded_file = gpserver.upload_file(CSVfile, CSVfile_path)  
    

    
    csvtofcs_job_spec.set_parameter("Input.CSV.data.file", uploaded_file.get_url())
    csvtofcs_job_spec.set_parameter("Output.FCS.file.name", "<Input.CSV.data.file_basename>.fcs")
    csvtofcs_job_spec.set_parameter("Range", "auto")
    csvtofcs_job_spec.set_parameter("Data.type", "auto")
    
    
    #
    csvtofcs_job = gpserver.run_job(csvtofcs_job_spec)
    output_list=csvtofcs_job.get_output_files()
    for file in output_list:
        print(file.get_url()) 
        data_result="https://aligogon:cytometry2021@cloud.genepattern.org/gp/rest/v1/jobs/" + str(csvtofcs_job.job_number) + "/download"
    #haciendo eso se bajaría un zip con ambos archivos
    return (data_result)
