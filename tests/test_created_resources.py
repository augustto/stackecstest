import os
from service.alb_service import ALBService  # Importe a nova classe

running_local = os.getenv("RUNNING_LOCAL")
alb_service = ALBService(running_local)

# Novo teste para o ALB
def test_alb_services():
    alb_service_response = alb_service.get_albs()
    load_balancers = alb_service_response.get("LoadBalancers")
    assert load_balancers, "Nenhum ALB encontrado"

    # Verificar se há pelo menos um ALB com o nome esperado
    alb_found = False
    for load_balancer in load_balancers:
        alb_name = load_balancer.get("LoadBalancerName")
        print(f"[ApplicationLoadBalancer]: {alb_name}")

        if "<albname>" in alb_name:
            alb_found = True
            print(f"[ALB Status]: {load_balancer.get('State', {}).get('Cosde')}")
            assert (
                load_balancer.get("State", {}).get("Code") == "active"
            ), "ALB não está ativo"

    assert alb_found, "ALB específico não encontrado"

if __name__ == "__main__":
    print("Executando teste de ALB...")
    try:
        resultado = test_alb_services()
        if resultado:
            print("\n✅ TESTE PASSOU: ALB verificado com sucesso!")
            exit(0)  # Código de saída para sucesso
    except AssertionError as e:
        print(f"\n❌ TESTE FALHOU: {str(e)}")
        exit(1)  # Código de saída para falha
    except Exception as e:
        print(f"\n❌ ERRO: {str(e)}")
        exit(1)  # Código de saída para falha