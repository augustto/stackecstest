import boto3
import logging

class ALBService:
    def __init__(self, running_locally=None):
        self.service_name = "elbv2"
        self.region_name = "us-east-1"
        self.client_elb = None
    
    def __create_client(self):
        try:
            # Criar cliente ELB
            self.client_elb = boto3.client(
                service_name=self.service_name, 
                region_name=self.region_name
            )
            print("Cliente ELB criado com sucesso")
        except Exception as e:
            print(f"Erro ao criar cliente ELB: {e}")
            logging.error("Erro ao estabelecer conexão com o ELB")
            logging.exception(e)
            raise e
    
    def get_albs(self):
        self.__create_client()
        try:
            # Buscar todos os load balancers
            response = self.client_elb.describe_load_balancers()
            
            # Filtrar apenas ALBs
            albs = [
                lb for lb in response.get("LoadBalancers", []) 
                if lb.get("Type") == "application"
            ]
            
            # Imprimir detalhes de cada ALB
            for lb in albs:
                print("\nDetalhes do Load Balancer:")
                print(f"Nome: {lb.get('LoadBalancerName')}")
                print(f"ARN: {lb.get('LoadBalancerArn')}")
                print(f"DNS Name: {lb.get('DNSName')}")
                
                # Tentar obter o status detalhado
                try:
                    detailed_status = self.get_load_balancer_status(lb.get('LoadBalancerArn'))
                    print(f"Status Detalhado: {detailed_status}")
                except Exception as e:
                    print(f"Erro ao obter status detalhado: {e}")
            
            print(f"\nALBs encontrados: {len(albs)}")
            return {"LoadBalancers": albs}
        
        except Exception as e:
            print(f"Erro ao obter ALBs: {e}")
            logging.error("Erro ao obter os ALBs")
            logging.exception(e)
            raise e
    
    def get_load_balancer_status(self, load_balancer_arn):
        try:
            # Obter estado dos targets
            target_groups = self.client_elb.describe_target_groups(
                LoadBalancerArn=load_balancer_arn
            )
            
            for tg in target_groups.get('TargetGroups', []):
                # Verificar o status dos targets
                targets = self.client_elb.describe_target_health(
                    TargetGroupArn=tg['TargetGroupArn']
                )
                
                print(f"\nGrupo de Destino: {tg.get('TargetGroupName')}")
                for target in targets.get('TargetHealthDescriptions', []):
                    print(f"Target: {target.get('Target', {}).get('Id')}")
                    print(f"Status: {target.get('TargetHealth', {}).get('State')}")
                    print(f"Descrição: {target.get('TargetHealth', {}).get('Description', 'N/A')}")
            
            return "Active"
        except Exception as e:
            print(f"Erro ao verificar status dos targets: {e}")
            return "Unknown"