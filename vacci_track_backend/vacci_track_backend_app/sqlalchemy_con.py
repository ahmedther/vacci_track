from sqlalchemy import Table, MetaData, create_engine, inspect
from sqlalchemy.orm import sessionmaker, declarative_base


class SqlAlchemyConnection:
    def __init__(self):
        username = "ibaehis"
        password = "ib123"
        host = "172.20.200.11"
        port = "1521"
        sid = "NEWDB1"

        # Construct the database URL
        url = f"oracle://{username}:{password}@{host}:{port}/{sid}"

        # Create the engine
        self.engine = create_engine(url)

        # create a metadata object
        self.metadata = MetaData()
        self.mp_patient = Table("mp_patient", self.metadata, autoload_with=self.engine)
        mp_inspector = inspect(self.mp_patient)
        mp_columns = mp_inspector.columns

    def make_connection(self):
        self.Session = sessionmaker(bind=self.engine)
        # create a base class for declarative models
        self.Base = declarative_base()
        # create a session to interact with the database
        self.session = self.Session()

    def get_employees_details_with_pr_num(self, pr_number):
        self.make_connection()
        # retrieve a patient by pr_number
        employee_data = (
            self.session.query(self.mp_patient)
            .filter(
                self.mp_patient.columns.alt_id2_no == pr_number,
                self.mp_patient.columns.alt_id2_type == "EML",
                self.mp_patient.columns.alt_id2_no.isnot(None),
            )
            .with_entities(
                self.mp_patient.columns.name_prefix,
                self.mp_patient.columns.first_name,
                self.mp_patient.columns.second_name,
                self.mp_patient.columns.family_name,
                self.mp_patient.columns.sex,
                self.mp_patient.columns.contact1_no,
                self.mp_patient.columns.contact2_no,
                self.mp_patient.columns.email_id,
                self.mp_patient.columns.pat_ser_grp_code,
            )
            .all()
        )

        self.close_connection()
        # close the session
        return employee_data

    def get_distict_prefix(self):
        self.make_connection()
        # retrieve a patient by pr_number
        distinct_gender = (
            self.session.query(self.mp_patient.columns.name_prefix).distinct().all()
        )

        self.close_connection()
        # close the session
        return distinct_gender

    def close_connection(self):
        self.session.close()

    # def get_employees_details_with_name(self, name):
    #     self.make_connection()
    #     # retrieve a patient by pr_number
    #     employee_data = (
    #         self.session.query(self.mp_patient)
    #         .filter(
    #             self.mp_patient.columns.patient_name.ilike(name),
    #             self.mp_patient.columns.alt_id2_type == "EML",
    #             self.mp_patient.columns.alt_id2_no.isnot(None),
    #         )
    #         .with_entities(
    #             self.mp_patient.columns.patient_name,
    #             self.mp_patient.columns.alt_id2_no,
    #             self.mp_patient.columns.contact1_no,
    #             self.mp_patient.columns.contact2_no,
    #             self.mp_patient.columns.email_id,
    #         )
    #         .first()
    #     )

    #     self.close_connection()
    #     # close the session
    #     return employee_data

    # def get_employees_details_with_pr_num_name(self, pr_number, name):
    #     self.make_connection()
    #     # retrieve a patient by pr_number
    #     employee_data = (
    #         self.session.query(self.mp_patient)
    #         .filter(
    #             self.mp_patient.columns.alt_id2_no == pr_number,
    #             self.mp_patient.columns.patient_name.ilike(name),
    #             self.mp_patient.columns.alt_id2_type == "EML",
    #             self.mp_patient.columns.alt_id2_no.isnot(None),
    #         )
    #         .with_entities(
    #             self.mp_patient.columns.patient_name,
    #             self.mp_patient.columns.alt_id2_no,
    #             self.mp_patient.columns.contact1_no,
    #             self.mp_patient.columns.contact2_no,
    #             self.mp_patient.columns.email_id,
    #         )
    #         .first()
    #     )

    #     self.close_connection()
    #     # close the session
    #     return employee_data


if __name__ == "__main__":
    sq = SqlAlchemyConnection()
    sq.get_employees_details_with_name("%ahmed islamuddin qureshi%")
# DATABASES = {
#       'default': {
#         'ENGINE': 'django.db.backends.oracle',
#         'NAME': 'NEWDB:1521/newdb.kdahit.com',
#         'NAME': ('(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=khdb-scan)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=newdb.kdahit.com)))'),
#         'USER': 'appluser',
#         'PASSWORD': 'appluser',
#     }
# }

# DATABASES = {
#       'default': {
#         'ENGINE': 'django.db.backends.oracle',
#         'NAME': ('(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=khdb-scan)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=newdb.kdahit.com)))'),
#         'USER': 'appluser',
#         'PASSWORD': 'appluser',
#     }
# }
#'HOST': 'khdb-scan',
# 'PORT': '1521',
# SELECT INSTANCE_NAME, INSTANCE_NUMBER, HOST_NAME FROM V$INSTANCE;

# set the database connection details


# create an engine to connect to the database

# create a sessionmaker to manage sessions with the database
