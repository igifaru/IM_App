from typing import Dict, List, Any

class AdviceService:
    def __init__(self):
        # Professional advice rules following Rwanda Agriculture Board (RAB) guidelines
        self.rules = {
            "Maize": {
                "general": {
                    "en": "Plant in rows with 75cm between rows and 25cm between plants. Apply NPK at planting.",
                    "rw": "Tera mu mirongo: 75cm hagati y'imirongo na 25cm hagati y'ibishyimbo. Shira NPK mu itera.",
                    "fr": "Plantez en lignes : 75 cm entre les rangs et 25 cm entre les plants. Appliquez le NPK."
                },
                "slope_tips": {
                    "en": "Use anti-erosion terraces and plant across the slope to prevent soil loss.",
                    "rw": "Kora amayira y'amazi kandi utere unyuranije n'umukubuko w'umusozi.",
                    "fr": "Utilisez des terrasses anti-érosives et plantez en travers de la pente."
                }
            },
            "Paddy rice": {
                "general": {
                    "en": "Maintain 2-5cm water level. Use NPK 17-17-17 and Urea in two splits.",
                    "rw": "Menya ko amazi ahoramo (2-5cm). Koresha ifumbire ya NPK na Urea mu byiciro bibiri.",
                    "fr": "Maintenez 2-5cm d'eau. Utilisez du NPK et de l'Urée en deux applications."
                }
            },
            "Bush bean": {
                "general": {
                    "en": "Spacing: 40cm x 10cm. Treat seeds with fungicide before planting.",
                    "rw": "Intera: 40cm x 10cm. Vura imbuto n'umuti wica uduhumburi mbere y'itera.",
                    "fr": "Espacement : 40 cm x 10 cm. Traitez les semences avec un fongicide."
                }
            },
            "Climbing bean": {
                "general": {
                    "en": "Provide strong stakes (2-3m). Use 40cm x 20cm spacing with 2 seeds per hole.",
                    "rw": "Shyiraho imishingiriro ikomeye (2-3m). Intera ni 40cm x 20cm, imbuto 2 mu mwobo.",
                    "fr": "Utilisez des tuteurs (2-3m). Espacement 40cm x 20cm, 2 graines par trou."
                }
            },
            "Irish potato": {
                "general": {
                    "en": "Use sprouted tubers (30-60g). Spacing: 75cm x 30cm. Earth up at 3 weeks.",
                    "rw": "Koresha imirama yameze (30-60g). Intera: 75cm x 30cm. Itira nyuma y'ibyumweru 3.",
                    "fr": "Tubercules germés (30-60g). Espacement 75cm x 30cm. Buttage après 3 semaines."
                }
            },
            "Sorghum": {
                "general": {
                    "en": "Spacing: 60cm x 15cm. Thin out to one plant per hole after 2 weeks.",
                    "rw": "Intera: 60cm x 15cm. Gabanya kugeza kuri rumwe mu mwobo nyuma y'ibyumweru 2.",
                    "fr": "Espacement : 60cm x 15cm. Éclaircissez à un plant par poquet après 2 semaines."
                }
            },
            "Wheat": {
                "general": {
                    "en": "Sow in rows 20cm apart. Use 100-125kg of seeds per hectare.",
                    "rw": "Tera mu mirongo ifite intera ya 20cm. Koresha ibiro 100-125 by'imbuto kuri hegitari.",
                    "fr": "Semez en lignes avec 20cm d'écart. Utilisez 100-125kg de semences par hectare."
                }
            },
            "Soybean": {
                "general": {
                    "en": "Spacing: 40cm x 10cm. Inoculate with Rhizobium for better nitrogen fixation.",
                    "rw": "Intera: 40cm x 10cm. Vanga imbuto na Rhizobium kugira ngo yimeze neza.",
                    "fr": "Espacement : 40cm x 10cm. Inoculez avec du Rhizobium pour fixer l'azote."
                }
            },
            "Groundnut": {
                "general": {
                    "en": "Spacing: 30cm x 10cm. Weed early but avoid weeding once flowering starts.",
                    "rw": "Intera: 30cm x 10cm. Bagara kare ariko wirinde kubagara iyo yatangiye kurabyo.",
                    "fr": "Espacement : 30cm x 10cm. Désherbez tôt mais évitez la floraison."
                }
            },
            "Cassava": {
                "general": {
                    "en": "Use healthy cuttings (25-30cm). Plant at 45 degree angle with 1m x 1m spacing.",
                    "rw": "Koresha inguri nzima (25-30cm). Tera unamitsye (45 degree) kuri intera ya 1m x 1m.",
                    "fr": "Boutures saines (25-30cm). Plantez à 45° avec un espacement de 1m x 1m."
                }
            },
            "Sweet potato": {
                "general": {
                    "en": "Plant 30cm vines on ridges spaced 1m apart. Ensure at least 2 nodes are buried.",
                    "rw": "Tera imigozi ya 30cm ku miringoti ya 1m. Menya ko nodes 2 zishyinguye.",
                    "fr": "Plantez des lianes de 30cm sur billons de 1m. Enterrez au moins 2 nœuds."
                }
            },
            "Banana (Cooking)": {
                "general": {
                    "en": "Spacing: 3m x 3m. Dig holes 60cm deep. Use organic mulch and prune suckers.",
                    "rw": "Intera: 3m x 3m. Cukura imyobo ya 60cm. Koresha isaso n'ifumbire uhangure imyobo.",
                    "fr": "Espacement : 3m x 3m. Trous de 60cm. Paillez et taillez les rejets."
                }
            },
            "Banana (Dessert)": {
                "general": {
                    "en": "Spacing: 3m x 3m. Support heavy bunches with poles. Control banana weevils.",
                    "rw": "Intera: 3m x 3m. Shingirira ibitoki biremereye. Rwanya iminyorogoto y'insina.",
                    "fr": "Espacement : 3m x 3m. Soutenez les régimes lourds. Luttez contre les charançons."
                }
            },
            "Banana (Beer)": {
                "general": {
                    "en": "Allow 3-4 suckers per mat. Ensure good drainage to prevent wilt diseases.",
                    "rw": "Reka insina 3-4 ku gitsinsi. Menya ko amazi atembera neza ngo wirinde indwara.",
                    "fr": "Laissez 3-4 rejets par touffe. Assurez un bon drainage contre le flétrissement."
                }
            },
            "Cocoyam (Taro)": {
                "general": {
                    "en": "Plant in moist soil with 60cm x 60cm spacing. Keep the area weed-free.",
                    "rw": "Tera mu butaka butose (60cm x 60cm). Menya ko hatarangwamo ibyatsi.",
                    "fr": "Plantez en sol humide (60cm x 60cm). Gardez la zone sans mauvaises herbes."
                }
            },
            "Yams": {
                "general": {
                    "en": "Plant in large mounds (1m apart). Provide stakes for the vines to climb.",
                    "rw": "Tera mu birundo binini (intera ya 1m). Shyiraho imishingiriro y'imigozi.",
                    "fr": "Plantez en grands monticules (1m). Prévoyez des tuteurs pour les lianes."
                }
            },
            "Dry peas": {
                "general": {
                    "en": "Spacing: 20cm x 5cm. Harvest when pods are dry and brittle.",
                    "rw": "Intera: 20cm x 5cm. Sarura iyo imigunzu yumye neza.",
                    "fr": "Espacement : 20cm x 5cm. Récoltez quand les gousses sont sèches."
                }
            },
            "Vegetables": {
                "general": {
                    "en": "Use nursery beds for seedlings. Ensure regular watering and apply compost.",
                    "rw": "Koresha indegero y'imboga. Vubira kenshi kandi ushyiremo imborera.",
                    "fr": "Utilisez des pépinières. Arrosez régulièrement et utilisez du compost."
                }
            },
            "Fruits": {
                "general": {
                    "en": "Space according to variety. Prune annually and control pests and diseases.",
                    "rw": "Intera biterwa n'ubwoko. Hangura buri mwaka kandi urwanye udukoko.",
                    "fr": "Espacement selon variété. Taillez annuellement et luttez contre les nuisibles."
                }
            },
            "Other cereals": {
                "general": {
                    "en": "Follow general cereal practices: row planting, thinning, and timely weeding.",
                    "rw": "Kurikiza amata bwiriza rusange y'ibinyampeke: gutera mu mirongo no kubagara.",
                    "fr": "Pratiques céréalières : semis en lignes, éclaircissage et désherbage."
                }
            },
            "Other crops": {
                "general": {
                    "en": "Follow Good Agricultural Practices: soil testing, quality seeds, and proper spacing.",
                    "rw": "Kurikiza amabwiriza y'ubuhinzi bwiza: imbuto nziza no kubungabunga ubutaka.",
                    "fr": "Suivez les bonnes pratiques agricoles : semences de qualité et entretien du sol."
                }
            }
        }
        
        self.fallback = {
            "en": "Ensure proper weeding and timely fertilizer application for optimal yield.",
            "rw": "Ibuka kubagara ku gihe no gushyiramo ifumbire nk'uko bikwiye.",
            "fr": "Assurez un désherbage adéquat et une application d'engrais à temps."
        }

    def get_expert_advice(self, crop: str, inputs: Dict[str, Any], lang: str = "en") -> str:
        lang = lang.lower()[:2]
        if lang not in ["en", "fr", "rw"]:
            lang = "en"
            
        advice_parts = []
        
        # 1. Get Crop General Advice
        crop_rules = self.rules.get(crop, {})
        general = crop_rules.get("general", {}).get(lang)
        if general:
            advice_parts.append(general)
        else:
            advice_parts.append(self.fallback.get(lang, self.fallback["en"]))
            
        # 2. Environmental Factors
        if inputs.get("slope") == "Yes":
            slope_tip = crop_rules.get("slope_tips", {}).get(lang)
            if not slope_tip:
                # General slope advice
                generic_slope = {
                    "en": "On sloped land, use ridges and anti-erosion measures like forward-sloping terraces.",
                    "rw": "Ku butaka buhanamye, koresha imiranyuro n'ingamba zo kurwanya isuri nk'amaterasi y'indinganire.",
                    "fr": "Sur les terrains en pente, utilisez des billons et des terrasses radicales."
                }
                slope_tip = generic_slope.get(lang)
            advice_parts.append(slope_tip)
            
        # 3. Fertilizer & Lime Context
        if inputs.get("used_lime") == 1:
            lime_tip = {
                "en": "Agricultural lime helps neutralize soil acidity. Apply it at least 2 weeks before planting.",
                "rw": "Ishura ryafasha kurwanya ubusharire bw'ubutaka. Richeteze ko rijyaho ibyumweru 2 mbere y'itera.",
                "fr": "La chaux aide à neutraliser l'acidité. Appliquez-la 2 semaines avant le semis."
            }
            advice_parts.append(lime_tip.get(lang))
        elif inputs.get("inorganic_fert") == 0 and inputs.get("organic_fert") == 0:
            fert_tip = {
                "en": "Consider using organic manure or inorganic fertilizers to restore soil nutrients.",
                "rw": "Tekereza gukoresha ifumbire y'imborera cyangwa mvaruganda kugira ngo wongere uburumbuke.",
                "fr": "Envisagez d'utiliser du fumier ou des engrais pour restaurer les nutriments."
            }
            advice_parts.append(fert_tip.get(lang))

        return " ".join([p for p in advice_parts if p])

advice_service = AdviceService()
