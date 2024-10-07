import os
from syftbox.lib import ClientConfig
import json
import opendp.prelude as dp
dp.enable_features('contrib')

app_name = os.path.basename(os.path.dirname(os.path.abspath(__file__)))

client_config = ClientConfig.load(
    os.path.expanduser("~/.syftbox/client_config.json")
)

input_folder = (
    f"{client_config.sync_folder}/{client_config.email}/app_pipelines/dundlersales/inputs/"
)
output_folder = (
    f"{client_config.sync_folder}/{client_config.email}/app_pipelines/dundlersales/done/"
)

os.makedirs(input_folder, exist_ok=True)
os.makedirs(output_folder, exist_ok=True)

input_file_path = f"{input_folder}my_sales_number.txt"
output_file_path = f"{output_folder}sales.json"

def add_dp_noise(value, epsilon):
    space = (dp.atom_domain(T=int), dp.absolute_distance(T=int))
    laplace_mechanism = dp.m.make_laplace(*space, scale=epsilon)
    
    return laplace_mechanism(value)

if os.path.exists(input_file_path):
    with open(input_file_path, "r") as f:
        content = f.read().strip()
        number = int(content)

    overview = {}
    overview[client_config.email] = int(add_dp_noise(number, 1.))

    with open(output_file_path, "w") as f:
        json.dump(overview, f)
else:
    print(f"Input file {input_file_path} does not exist.")