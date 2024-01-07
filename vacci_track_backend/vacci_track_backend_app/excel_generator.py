import pandas as pd
import os
from pathlib import Path
from datetime import datetime


def excel_generator(data, column, page_name):
    page_name = page_name if len(page_name) <= 31 else page_name[:31]
    # gives you location of manage.py
    current_dir = os.path.dirname(os.path.abspath(__file__))
    curret_path = Path(current_dir)
    parent_path = curret_path.parent
    # write the print fuction in error log. Test on Apache reverse proxy but not on nginx
    # sys.stderr.write(excel_file_path)

    excel_file_path = f"{parent_path}/excel_media/{page_name}.xlsx"

    # creates a log file and report errors
    # logging.basicConfig(filename="report_error.log", level=logging.DEBUG)
    # logging.error(f"Error on {add_time_to_page_string} :")
    # sys.stderr.write(excel_file_path)

    excel_data = pd.DataFrame(data=data, columns=list(column))

    # Set destination directory to save excel.
    generate_excel = pd.ExcelWriter(
        excel_file_path,
        engine="xlsxwriter",
        datetime_format="dd-mm-yyyy hh:mm:ss",
        date_format="dd-mm-yyyy",
    )

    # Write excel to file using pandas to_excel
    excel_data.to_excel(generate_excel, startrow=0, sheet_name=page_name, index=False)

    # Indicate workbook and worksheet for formatting
    workbook = generate_excel.book
    worksheet = generate_excel.sheets[page_name]

    # Iterate through each column and set the width == the max length in that column. A padding length of 2 is also added.
    for i, col in enumerate(excel_data.columns):
        # find length of column i
        try:
            max_length = excel_data[col].astype(str).str.len().max()
            column_len = max_length if max_length <= 50 else 50
        except:
            column_len = 12

        # Setting the length if the column header is larger
        # than the max column value length
        try:
            column_len = max(column_len, len(col)) + 4

        except:
            column_len = 12

        # set the column length
        worksheet.set_column(i, i, column_len)

    generate_excel.close()
    return excel_file_path
