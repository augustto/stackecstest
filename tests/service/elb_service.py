import os
import boto3
import logging
from service.sts_service import STSService


class ECSService:
    def init(self, running_locally):
        self.running_locally = running_locally
        self.service_name = "ecs"
        self.region_name = "us-east-1"
        self.client_ecs = None

    def __create_client(self):
        try:
            if self.running_locally.eq("enabled"):
                boto3.setup_default_session(profile_name=os.getenv("PROFILE_NAME"))
                self.client_ecs = boto3.client(
                    service_name=self.service_name, region_name=self.region_name
                )
                print("credentials OK")
            else:
                credentials = STSService().get_credentials_assume_role()
                self.client_ecs = boto3.client(
                    service_name=self.service_name,
                    region_name=self.region_name,
                    aws_access_key_id=credentials["AccessKeyId"],
                    aws_secret_access_key=credentials["SecretAccessKey"],
                    aws_session_token=credentials["SessionToken"],
                )
        except Exception as e:
            print(e)
            logging.error("Erro ao estabelecer conexão com o API GTW")
            logging.exception(e)
            raise e

    def get_ecs_clusters(self) -> dict:
        self.__create_client()
        try:
            return self.client_ecs.list_clusters()
        except Exception as e:
            print(e)
            logging.error("Erro ao obter os VPCs Links")
            logging.exception(e)
            raise e
