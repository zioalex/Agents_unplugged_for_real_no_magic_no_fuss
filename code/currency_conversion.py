"""Currency conversion example using ECB exchange rates."""
import logging
import requests
from xml.etree import ElementTree as ET

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ECB namespace for XML parsing
ECB_NS = {'gesmes': 'http://www.gesmes.org/xml/2002-08-01',
          'eurofxref': 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref'}


def get_jpy_rate() -> float | None:
    """Fetch current EUR to JPY exchange rate from ECB."""
    url = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'

    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
    except requests.RequestException as e:
        logger.error("Error fetching exchange rates: %s", e)
        return None

    try:
        root = ET.fromstring(response.content)
    except ET.ParseError as e:
        logger.error("Error parsing XML response: %s", e)
        return None

    # ECB XML uses Cube elements with 'currency' and 'rate' attributes (not child elements)
    for cube in root.findall('.//eurofxref:Cube[@currency]', ECB_NS):
        currency = cube.get('currency')
        rate_str = cube.get('rate')
        if currency == 'JPY' and rate_str:
            try:
                return float(rate_str.replace(',', '.'))
            except ValueError:
                logger.error("Invalid rate format: %s", rate_str)
                return None

    logger.warning("JPY rate not found in ECB data")
    return None


def convert_eur_to_jpy(amount_eur: float) -> float | None:
    """Convert EUR amount to JPY using current ECB rate."""
    rate = get_jpy_rate()
    if rate is None:
        return None
    return amount_eur * rate


if __name__ == "__main__":
    amount_yen = convert_eur_to_jpy(100)
    if amount_yen is not None:
        logger.info("100 Euro is approximately %.2f Japanese Yen", amount_yen)
    else:
        logger.error("Could not retrieve exchange rate")
